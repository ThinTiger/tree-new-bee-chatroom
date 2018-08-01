package com.tnb.chatroom.socket;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import javax.websocket.*;
import javax.websocket.server.PathParam;
import javax.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;
import java.util.concurrent.CopyOnWriteArrayList;

/**
 * @author:wang.jiang
 * @date:2018/7/31 16:15
 */

@ServerEndpoint("/chatroom-ws/{roomId}/{userId}")
@Component
public class ChatRoomWebSocket {
    private static CopyOnWriteArrayList<ChatRoomWebSocket> webSockets = new CopyOnWriteArrayList<>();
    private static ConcurrentMap<Integer, Integer> onlineCountMap = new ConcurrentHashMap<>();
    private Logger logger = LoggerFactory.getLogger(getClass());
    private Session session;
    private int roomId;
    private int userId;

    public static synchronized int getOnlineCount() {
        return webSockets.size();
    }

    public static synchronized int getUserCountByRoomId(int roomId) {
        return onlineCountMap.getOrDefault(roomId, 0);
    }

    @OnOpen
    public void onOpen(@PathParam("roomId") int roomId, @PathParam("userId") int userId, Session session) {
        this.session = session;
        this.roomId = roomId;
        this.userId = userId;
        webSockets.add(this);
        updateOnlineCount();
        logger.info("用戶{}進入房間{}", userId, roomId);

    }

    @OnClose
    public void onClose() {
        webSockets.remove(this);
        updateOnlineCount();
        logger.info("用戶{}退出房間{}", userId, roomId);
    }

    @OnMessage
    public void onMessage(ByteBuffer message) {
        logger.info("用戶{}在房間{}發送消息：{}", userId, roomId, message);
        for (ChatRoomWebSocket webSocket : webSockets) {
            webSocket.sendMessage(message);
        }
    }

    @OnMessage
    public void onMessage(String message) {
        logger.info("用戶{}在房間{}發送消息：{}", userId, roomId, message);
        for (ChatRoomWebSocket webSocket : webSockets) {
            webSocket.sendMessage(message);
        }
    }

    private void sendMessage(ByteBuffer message) {
        try {
            this.session.getBasicRemote().sendBinary(message);
        } catch (IOException e) {
            logger.error("發送消息異常", e);
        }
    }

    private void sendMessage(String message) {
        try {
            this.session.getBasicRemote().sendText(message);
        } catch (IOException e) {
            logger.error("發送消息異常", e);
        }
    }

    private void updateOnlineCount() {
        onlineCountMap.remove(roomId);
        onlineCountMap.putIfAbsent(roomId, getOnlineCount());
    }

    @OnError
    public void onError(Session session, Throwable throwable) {
        logger.error("異常了..", throwable);
    }
}
