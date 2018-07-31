package com.tnb.chatroom.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * @author:wang.jiang
 * @date:2018/7/31 18:46
 */
@RestController
@RequestMapping("rooms")
public class ChatRoomController {

    @GetMapping
    @RequestMapping("/{roomId}/userCount")
    public int getUserCountByRoomId(@PathVariable int roomId){
        return 0;
    }
}
