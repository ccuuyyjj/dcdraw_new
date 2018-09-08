<%@ page language="java" import="java.util.*, java.io.*" contentType="text/html" pageEncoding="UTF-8"%><%
	File target = new File(application.getRealPath("/"), "recent-db");
	if(!target.exists()) target.createNewFile();
	StringBuilder winner_str = new StringBuilder();
	while(!target.canRead()){
        Thread.sleep(100);
    }
	BufferedReader reader = new BufferedReader(new FileReader(target));
	String line = reader.readLine();
    while (line != null) {
    	winner_str.append(line);
    	winner_str.append(System.lineSeparator());
        line = reader.readLine();
    }
    reader.close();%><!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="ko">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
</head>
<body style="background:#D6E7FB; overflow: hidden;">
<div style="font-weight: bold;font-size: 0.8em;margin-left: 20px; overflow: hidden;"><%=winner_str.toString()%></div>
</body>
</html>