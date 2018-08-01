package com.tnb.chatroom.service;

import com.tnb.chatroom.socket.ChatRoomWebSocket;
import org.springframework.stereotype.Service;

/**
 * @author:wang.jiang
 * @date:2018/7/31 18:56
 */
@Service
public class ChatRoomService {

    public int getUserCountByRoomId(int roomId){
        return ChatRoomWebSocket.getUserCountByRoomId(roomId);
    }
}
