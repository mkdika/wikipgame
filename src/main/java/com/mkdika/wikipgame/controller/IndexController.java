
package com.mkdika.wikipgame.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 *
 * @author Maikel Chandika <mkdika@gmail.com>
 * 
 */
@Controller
public class IndexController {
    
    @RequestMapping("/")
    public String index(){
        return "index";
    }    
}
