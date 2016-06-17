package com.mkdika.wikipgame.entity;

/**
 *
 * @author Maikel Chandika <mkdika@gmail.com>
 */
public class ResponseNode {

    /*
        0 = error
        1 = success
     */
    private int code;
    private String errmsg;
    private String title;
    private String url;
    private String nextTitle;
    private String nextUrl;

    public ResponseNode() {

    }

    public ResponseNode(int code, String errmsg, String title, String url,String nextTitle,String nextUrl) {
        this.code = code;
        this.errmsg = errmsg;
        this.title = title;
        this.url = url;
        this.nextTitle = nextTitle;
        this.nextUrl = nextUrl;
    }

    public int getCode() {
        return code;
    }

    public void setCode(int code) {
        this.code = code;
    }

    public String getErrmsg() {
        return errmsg;
    }

    public void setErrmsg(String errmsg) {
        this.errmsg = errmsg;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public String getNextTitle() {
        return nextTitle;
    }

    public void setNextTitle(String nextTitle) {
        this.nextTitle = nextTitle;
    }

    public String getNextUrl() {
        return nextUrl;
    }

    public void setNextUrl(String nextUrl) {
        this.nextUrl = nextUrl;
    }        
}
