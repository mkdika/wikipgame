<%@page session="false"%>
<%@taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="en">
    <head> 
        <c:url var="home" value="/" scope="request" />
        <title>Wikipedia Philosophy Game</title>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>

        <spring:url value="/resources/static/css/toastr.min.css"
                    var="toastrCss" />
        <link href="${toastrCss}" rel="stylesheet" />

        <style type="text/css">           
            input {
                float:right;
                width:300px;
                border:1px solid #dadada;
                border-radius:7px;
                font-size:15px;
                padding:5px;
                margin-top:-10px;    
            }

            input:focus { 
                outline:none;
                border-color:#9ecaed;
                box-shadow:0 0 10px #9ecaed;
            }

            .node {
                stroke: #666;
                stroke-width: 1.5px;
            }

            .link {
                fill: none;
                stroke: #333;
                stroke-opacity: .6;
                stroke-width: 1.5px;
            }
        </style>

        <spring:url value="/resources/static/js/jquery-1.12.4.min.js"
                    var="jqueryJs" />
        <spring:url value="/resources/static/js/toastr.min.js"
                    var="toastrJs" />        
        <spring:url value="/resources/static/js/d3.min.js"
                    var="d3Js" />

        <script src="${jqueryJs}"></script>
        <script src="${toastrJs}"></script>        
        <script src="${d3Js}"></script>

        <script>
            toastr.options = {
                "closeButton": true,
                "debug": false,
                "newestOnTop": true,
                "progressBar": false,
                "positionClass": "toast-top-center",
                "preventDuplicates": false,
                "onclick": null,
                "showDuration": "300",
                "hideDuration": "1000",
                "timeOut": "3000",
                "extendedTimeOut": "1000",
                "showEasing": "swing",
                "hideEasing": "linear",
                "showMethod": "fadeIn",
                "hideMethod": "fadeOut"
            }
        </script>       
    </head>
    <body>
        <div class="progress"></div>
        <br/>
        <div style="width:320px;margin:0 auto;" align=center>            
            <form id="search-form">
                <div >  
                    <div style="float: left;">
                        <input type="text" name="searchterm" id="title" placeholder="Please input the Wikipedia search title"/>
                    </div>

                </div>

            </form>          
            <br/>            
        </div>
        <div id="feedback"></div>
        <br/>
        <div id="feedbackFnet"></div>                

        <script>
            var counter = 0;
            var fnet = {
                "nodes": [],
                "links": []
            };

            // settings for Force-directed Graph
            var height = 450, width = 960;
            var nodes = fnet.nodes, links = fnet.links;
            var color = d3.scale.category20();

            var force = d3.layout.force()
                    .linkDistance(80)
                    .charge(-300)
                    .size([width, height])
                    .nodes(nodes)
                    .links(links);

            force.on("tick", function () {
                link.attr("x1", function (d) {
                    return d.source.x;
                })
                        .attr("y1", function (d) {
                            return d.source.y;
                        })
                        .attr("x2", function (d) {
                            return d.target.x;
                        })
                        .attr("y2", function (d) {
                            return d.target.y;
                        });
                node.attr("transform", function (d) {
                    return "translate (" + d.x + "," + d.y + ")";
                });
            });

            var svg = d3.select("body").append("svg")
                    .attr("id", "svg")
                    .attr("width", width)
                    .attr("height", height);

            svg.append("g").attr("class", "links");
            svg.append("g").attr("class", "nodes");


            var link = svg.select(".links").selectAll(".link");
            var node = svg.select(".nodes").selectAll(".node");



            function UpdateGraph() {
                force.start();
                link = link.data(force.links());
                link.enter().append("line").attr("class", "link");
                link.exit().remove();
                node = node.data(force.nodes());
                node.enter().append("g")
                        .attr("class", "node")
                        .call(force.drag);
                node.append("circle")
                        .attr("r", 12)
                        .style("fill", function (d) {
                            return color(d.group);
                        });
                node.append("svg:a")
                        .attr("xlink:href", function (d) {
                            return d.url;
                        })
                        .attr("target", "_blank")
                        .append("text")
                        .attr("x", 11)
                        .attr("dy", ".35em")
                        .attr("text-anchor", "start")
                        .text(function (d) {
                            return d.name;
                        });

                node.exit().remove();
            }

            jQuery(document).ready(function ($) {
                $("#search-form").submit(function (event) {
                    counter = 0;

                    fnet.nodes.splice(0, fnet.nodes.length);
                    fnet.links.splice(0, fnet.links.length);
                    nodes.splice(0, nodes.length);
                    links.splice(0, links.length);
                    UpdateGraph();

                    // Prevent the form from submitting via the browser.
                    event.preventDefault();

                    var SearchTerm = {};
                    SearchTerm["title"] = $("#title").val();
                    searchViaAjax(SearchTerm);
                });
            });

            function searchViaAjax(SearchTerm) {

                $.ajax({
                    type: "POST",
                    contentType: "application/json",
                    mimeType: 'application/json',
                    url: "/search",
                    data: JSON.stringify(SearchTerm),
                    dataType: 'json',
                    timeout: 100000,
                    success: function (data) {
                        console.log("SUCCESS: ", data);
                        display(data);
                    },
                    error: function (e) {
                        console.log("ERROR: ", e);
                        display(e);
                    },
                    done: function (e) {
                        console.log("DONE");
                        enableSearchButton(true);
                    }
                });

            }

            function display(data) {
                $("#term").val("");

                //                var json = "<h4>Ajax Response</h4><pre>"
                //                        + JSON.stringify(data, null, 4) + "</pre>";
                //                $('#feedback').html(json);

                if ($(data).attr('code') == 0) {
                    toastr.info($(data).attr('errmsg'));
                } else if ($(data).attr('code') == 1) {
                    fnet.nodes.push(
                            {"name": $(data).attr('title'), "url": $(data).attr('url'), "group": counter}
                    );
                    if (counter > 0) {
                        fnet.links.push(
                                {"source": (counter - 1), "target": counter}
                        );
                    }
                    UpdateGraph();

                    counter = counter + 1;
                    var SearchTerm = {};
                    SearchTerm["title"] = $(data).attr('nextTitle');
                    setTimeout(function () {
                        searchViaAjax(SearchTerm);
                    }, 500);
                } else if ($(data).attr('code') == 2) {
                    fnet.nodes.push(
                            {"name": $(data).attr('title'), "url": $(data).attr('url'), "group": counter}
                    );

                    if (counter > 0) {
                        fnet.links.push(
                                {"source": (counter - 1), "target": counter}
                        );
                    }

                    UpdateGraph();
                    toastr.info($(data).attr('errmsg'));
                }
//                                var json2 = "<h4>Fnet Response</h4><pre>"
//                                        + JSON.stringify(fnet, null, 4) + "</pre>";
//                                $('#feedbackFnet').html(json2);
            }
        </script>
    </body> 
</html>
