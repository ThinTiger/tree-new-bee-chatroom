package com.tnb.chatroom.socket;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import javax.websocket.*;
import javax.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.util.concurrent.CopyOnWriteArrayList;

/**
 * @author:wang.jiang
 * @date:2018/7/31 16:15
 */

@ServerEndpoint("/chatroom-ws")
@Component
public class ChatRoomWebSocket {

    private static CopyOnWriteArrayList<ChatRoomWebSocket> webSockets = new CopyOnWriteArrayList<>();
    private Logger logger = LoggerFactory.getLogger(getClass());
    private Session session;

    @OnOpen
    public void onOpen(Session session) {
        this.session = session;
        webSockets.add(this);
        logger.info("有新用戶加入..");

    }

    @OnClose
    public void onClose() {
        webSockets.remove(this);
        logger.info("有用戶退出..");
    }

    @OnMessage
    public void onMessage(String message) {
        logger.info("來自客戶端的消息:{}", message);
        for (ChatRoomWebSocket webSocket : webSockets) {
            webSocket.sendMessage(message);
        }
    }

    private void sendMessage(String message) {
        try {
            this.session.getBasicRemote().sendText(message);
        } catch (IOException e) {
            logger.error("發送消息異常", e);
        }
    }

    @OnError
    public void onError(Session session, Throwable throwable) {
        logger.error("異常了..", throwable);
    }

    public int getOnlineCount() {
        return webSockets.size();
    }
}
