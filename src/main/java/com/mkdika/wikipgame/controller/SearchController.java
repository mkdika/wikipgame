package com.mkdika.wikipgame.controller;

import com.mkdika.wikipgame.entity.ResponseNode;
import com.mkdika.wikipgame.entity.SearchTerm;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import org.jsoup.Connection;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.select.Elements;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

/**
 *
 * @author Maikel Chandika <mkdika@gmail.com>
 */
@RestController
public class SearchController {

    private final String WIKIPEDIA_EN_SEARCH = "http://en.wikipedia.org/w/index.php?title=${title}&printable=yes";
    private final String WIKIPEDIA_EN_NORMAL = "http://en.wikipedia.org/wiki/";
    private List<String> nodes = new ArrayList<>();

    @RequestMapping(value = "/search", method = RequestMethod.POST)
    public ResponseNode search(@RequestBody SearchTerm searchterm) throws IOException {
        ResponseNode responseNode = null;

        if (searchterm == null || searchterm.getTitle().trim().isEmpty()) {
            nodes.clear();
            return new ResponseNode(0, "Search title cant empty.", "", "http://en.wikipedia.org", "", "http://en.wikipedia.org");
        } else {
            String title = "", link = "", nextTitle = "", nextLink = "";
            title = searchterm.getTitle().replace("_", " ");
            link = WIKIPEDIA_EN_NORMAL + title;
            nodes.add(title.toLowerCase());

            if (title.equalsIgnoreCase("philosophy")) {
                nodes.clear();
                return responseNode = new ResponseNode(2, "Done! reach the Philosophy", title, link, nextTitle, nextLink);
            }

            Connection con = null;
            Connection.Response resp = null;
            int respcode = 0;

            try {
                con = Jsoup.connect(WIKIPEDIA_EN_SEARCH.replace("${title}", searchterm.getTitle().trim()))
                        .userAgent("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.21 (KHTML, like Gecko) Chrome/19.0.1042.0 Safari/535.21")
                        .ignoreContentType(true).ignoreHttpErrors(true)
                        .timeout(10000);
                resp = con.execute();
                respcode = resp.statusCode();
            } catch (java.net.UnknownHostException e) {
                return new ResponseNode(0, "Cant reach site en.wikipedia.org", "", "http://en.wikipedia.org", "", "http://en.wikipedia.org");
            }

            Document document = con.get();
            Elements links = document.select("p > a");
            if (links.size() < 1) {
                links = document.select("li > a");
            }

            for (int i = 0; i < links.size(); i++) {
                if (isFirstRealLink(links.get(i).toString()) && (!nodes.contains(links.get(i).attr("href").substring(6).toLowerCase()))) {
                    nextTitle = links.get(i).attr("href").substring(6);
                    nextLink = WIKIPEDIA_EN_NORMAL + nextTitle;
                    break;
                }
            }
            return responseNode = new ResponseNode(1, "", title, link, nextTitle, nextLink);
        }
    }

    public boolean isFirstRealLink(String link) {
        return (link.contains("wiki") && !link.contains("Greek") && !link.contains("Latin") && !link.contains("wiktionary") && !link.contains("File:"));
    }
}
