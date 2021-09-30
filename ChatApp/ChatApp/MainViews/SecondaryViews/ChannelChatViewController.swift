//
//  ChannelChatViewController.swift
//  ChatApp
//
//  Created by Sophia Zhu on 9/29/21.
//


import UIKit
import MessageKit
import InputBarAccessoryView
import Gallery
import RealmSwift  //local databsae

class ChannelChatViewController: MessagesViewController {


    
    
    // MARK: - vars
    private var chatId = ""
    private var recipientId = ""
    private var recipientName = ""
    
    var channel: Channel!
    
    
    open lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)
    
    let currentUser = MKSender(senderId: User.currentId, displayName: User.currentUser!.username)
    
    let refreshController = UIRefreshControl()
    var gallery: GalleryController!
    
    var displayingMessagesCount = 0
    var maxMessageNumber = 0
    var minMessageNumber = 0
    
    var mkMessages: [MKMessage] = []
    
    var allLocalMessages: Results<LocalMessage>!
    let realm = try! Realm()
    let micButton = InputBarButtonItem()
    
    
    // Listeners
    var notificationToken: NotificationToken?
    
    var longPressGesture: UILongPressGestureRecognizer! //recognize when click microphone
    var audioFileName = "" //where to save
    var audioDuration: Date! //
    
    
    
    
    // MARK: - Inits
    init(channel: Channel) {
        super.init(nibName: nil, bundle: nil) //if not add this, will show error: 'super.init' isn't called on all paths before returning from initializer
        self.chatId = channel.id
        self.recipientId = channel.id
        self.recipientName = channel.name
        self.channel = channel
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        
        configureMessageCollectionView()
        configureGestureRecognizer()
        configureMessageInputBar()
        
        configureLeftBarButton()
        configureCustomTitle()
        
        loadChats()
        listenForNewChats()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        FirebaseRecentListener.shared.resetRecentCounter(chatRoomId: chatId)
    }
    
    override func viewWillDisappear(_ animated: Bool){
        super.viewWillDisappear(animated)
        FirebaseRecentListener.shared.resetRecentCounter(chatRoomId: chatId)
        audioController.stopAnyOngoingPlaying()
    }
    
    
    // MARK: - Configuration
    private func configureMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        
        scrollsToBottomOnKeyboardBeginsEditing = true //when we are at top/middle, if click keyboard, will scrooldown to bottom
        maintainPositionOnKeyboardFrameChanged = true
        messagesCollectionView.refreshControl = refreshController
        
        
    }
    
    private func configureGestureRecognizer() {
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(recordAudio))
        longPressGesture.minimumPressDuration = 0.5 //press at least 0.5 second before it starts to record
        longPressGesture.delaysTouchesBegan = true
        
    }
    
    
    
    private func configureMessageInputBar() {
        //hide input bar
        messageInputBar.isHidden = channel.adminId != User.currentId
        
        messageInputBar.delegate = self
        let attachButton = InputBarButtonItem()
        attachButton.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        attachButton.setSize(CGSize(width: 30, height: 30), animated: false)
        
        attachButton.onTouchUpInside { (item) in
//            print("attach button pressed")
            self.actionAttachMessage()
            
        }
        
        micButton.image = UIImage(systemName: "mic.fill",  withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        micButton.setSize(CGSize(width: 30, height: 30), animated: false)
        
        //add gesture recognizer
        micButton.addGestureRecognizer(longPressGesture)
        
        
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        
        updateMicButtonStatus(show: true)
        
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
    }
    
    func updateMicButtonStatus(show: Bool){
        if show {
            messageInputBar.setStackViewItems([micButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 30, animated: true)
        } else {
            messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: true)
            messageInputBar.setRightStackViewWidthConstant(to: 55, animated: false)
        }
    }
    
    
    
    private func configureLeftBarButton() {
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(self.backButtonPressed))]
    }
    
    private func configureCustomTitle() {
        self.title = channel.name
    }
    
    // MARK: - Load Chats
    private func loadChats() {
        
        let predicate = NSPredicate(format: "chatRoomId = %@", chatId)
        allLocalMessages = realm.objects(LocalMessage.self).filter(predicate).sorted(byKeyPath: kDATE, ascending: true)
        if allLocalMessages.isEmpty {
            checkForOldChats()
        }
        
        
        //        print("we have \(allLocalMessages.count) messages")
        notificationToken = allLocalMessages.observe({ (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                self.insertMessages()
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom(animated: true) //always show bottom msg
//                print("we have \(self.allLocalMessages.count) messages")
            case .update(_, _, let insertions, _):
                for index in insertions {
                    print("new message \(self.allLocalMessages[index].message)")
                }
            case .error(let error):
                print("Error on new insertion ", error.localizedDescription)
            }
        })
    }
    
    
    private func listenForNewChats() {
        
        FirebaseMessageListener.shared.listenForNewChats(User.currentId, collectionId: chatId, lastMessageDate: lastMessageDate())
        
    }
    
    //check once we load from database
    private func checkForOldChats() {
        
//        print("check for old chats")
        FirebaseMessageListener.shared.checkForOldChats(User.currentId, collectionId: chatId)
    }
    
    
    // MARK: - Insert messages
    
    
    
    
    //going through loop and calls insertMessage,
    private func insertMessages() {
        //always load certain amount of messages
        maxMessageNumber = allLocalMessages.count - displayingMessagesCount
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        for i in minMessageNumber..<maxMessageNumber {
            insertMessage(allLocalMessages[i])
            
        }
    }
    
    //take a local message convert it into a message
    private func insertMessage(_ localMessage: LocalMessage) {
        
        
        let incoming = IncomingMessage(_collectionView: self)
        self.mkMessages.append(incoming.createMessage(localMessage: localMessage)!)
        displayingMessagesCount += 1
        
    }
    
    
    private func loadMoreMessages(maxNumber: Int, minNumber: Int) {
        
        maxMessageNumber = minNumber - 1
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        for i in (minMessageNumber...maxMessageNumber).reversed() {
                insertOlderMessage(allLocalMessages[i])
            
        }
    }
    
    
    private func insertOlderMessage(_ localMessage: LocalMessage) {
//        print("inserted message")
        let incoming = IncomingMessage(_collectionView: self)
        self.mkMessages.insert(incoming.createMessage(localMessage: localMessage)!, at: 0)
     
        displayingMessagesCount += 1
        
    }
    
    
    // MARK: - Actions
    func messageSend(text: String?, photo: UIImage?, video: Video?, audio: String?, location: String?, audioDuration: Float = 0.0) {
//        print("sending text ", text)
//        print("messageSend")
        OutgoingMessage.send(chatId: chatId, text: text, photo: photo, video: video, audio: audio, audioDuration: audioDuration, location: location, memberIds: [User.currentId, recipientId])

    }
    
    @objc func backButtonPressed() {
        FirebaseRecentListener.shared.resetRecentCounter(chatRoomId: chatId)
        //TODO: remove listeners
        removeListeners()
        self.navigationController?.popViewController(animated: true)
    }
    
    private func actionAttachMessage() {
        //hide keyboard
        messageInputBar.inputTextView.resignFirstResponder()
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { (alert) in
//            print("show camera")
            self.showImageGallery(camera: true)
        }
        let shareMedia = UIAlertAction(title: "Library", style: .default) { (alert) in
//            print("show library")
            self.showImageGallery(camera: false)

        }
        let shareLocation = UIAlertAction(title: "Share Location", style: .default) { (alert) in
            if let _ = LocationManager.shared.currentLocation {
                self.messageSend(text: nil, photo: nil, video: nil, audio: nil, location: kLOCATION)
            } else {
                
                print("no access to location")
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
          
        takePhotoOrVideo.setValue(UIImage(systemName: "camera"), forKey: "image")
        shareMedia.setValue(UIImage(systemName: "photo.fill"), forKey: "image")
        shareLocation.setValue(UIImage(systemName: "mappin.and.ellipse"), forKey: "image")

        
        optionMenu.addAction(takePhotoOrVideo)
        optionMenu.addAction(shareMedia)
        optionMenu.addAction(shareLocation)
        optionMenu.addAction(cancelAction)
            
        self.present(optionMenu, animated: true, completion: nil)

        
    }


    
    // MARK: -UIScrollViewDelegate
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshController.isRefreshing {
            
            if displayingMessagesCount < allLocalMessages.count {
                //load earlier messages
                self.loadMoreMessages(maxNumber: maxMessageNumber, minNumber: minMessageNumber)
                
                messagesCollectionView.reloadDataAndKeepOffset()
            }
            
            refreshController.endRefreshing()
        }
    }
    
  
    
    //MARK: -Helpers
    private func removeListeners() {
        FirebaseMessageListener.shared.removeListener()
        
    }
    private func lastMessageDate() -> Date {
        
        let lastMessageDate = allLocalMessages.last?.date ?? Date()
        return Calendar.current.date(byAdding: .second, value: 1, to: lastMessageDate) ?? lastMessageDate
    }
    
    // MARK: - Gallery
    private func showImageGallery(camera: Bool) {
        gallery = GalleryController()
        gallery.delegate = self
        Config.tabsToShow = camera ? [.cameraTab] : [.imageTab, .videoTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        Config.VideoEditor.maximumDuration = 30 //no more than 30seconds
        
        
        self.present(gallery, animated: true, completion: nil)
        
    }
    
    
    //MARK: - AudioMessages
    @objc func recordAudio() {
        switch longPressGesture.state {
        case .began:
            audioDuration = Date()
            audioFileName = Date().stringDate()
            //start recording
            AudioRecorder.shared.startRecording(fileName: audioFileName)
        case .ended:
            //stop recording
            AudioRecorder.shared.finishRecording()
        
        //check file save successfully
            if fileExistsAtPath(path: audioFileName + ".m4a") {
                //send message
                let audioD = audioDuration.interval(ofComponent: .second, from: Date())
                
                messageSend(text: nil, photo: nil, video: nil, audio: audioFileName, location: nil, audioDuration: audioD)
            } else {
                print("no audio file")
            }
            audioFileName = ""
        @unknown default:
            print("unknown")
        }
    }
    
}


extension ChannelChatViewController : GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
//        print("we have selected \(images.count) images")
        
        if images.count > 0 {
            images.first!.resolve { (image) in //convert to uiimage
                self.messageSend(text: nil, photo: image, video: nil, audio: nil, location: nil)
            }
            
        }
        controller.dismiss(animated: true, completion: nil)

    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        self.messageSend(text: nil, photo: nil, video: video, audio: nil, location: nil)
        controller.dismiss(animated: true, completion: nil)

    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        
        controller.dismiss(animated: true, completion: nil)

    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    
}
