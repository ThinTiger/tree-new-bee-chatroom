package com.tnb.chatroom.service;

import com.tnb.chatroom.socket.ChatRoomWebSocket;
import org.springframework.stereotype.Service;

import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

/**
 * @author:wang.jiang
 * @date:2018/7/31 18:56
 */
@Service
public class ChatRoomService {
    private ConcurrentMap<Integer,ChatRoomWebSocket> map = new ConcurrentHashMap<>();

}
