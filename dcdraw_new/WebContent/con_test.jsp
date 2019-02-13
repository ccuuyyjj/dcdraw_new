<%@ page language="java" contentType="application/json" pageEncoding="UTF-8" import="java.io.*,java.net.HttpURLConnection, java.net.URL, org.kopitubruk.util.json.*"%><%
response.setHeader("Cache-Control", "no-cache");
JsonObject json = new JsonObject();
String url_str = "https://gall.dcinside.com/_js/crossDomainStorage.html?time=" + System.currentTimeMillis();
json.add("checkURL", url_str);
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
long ping = System.currentTimeMillis();
HttpURLConnection connection = null;
try{
	URL url = new URL(url_str);
	connection = (HttpURLConnection) url.openConnection();
	connection.setRequestMethod("GET");
	connection.setConnectTimeout(5000);
	connection.setReadTimeout(5000);
	connection.connect();
	
	String body = null;
	try (InputStream in = connection.getInputStream();
            ByteArrayOutputStream bao = new ByteArrayOutputStream()) {
        byte[] buf = new byte[1024 * 8];
        int length = 0;
        while ((length = in.read(buf)) != -1) {
        	bao.write(buf, 0, length);
        }
        body = new String(bao.toByteArray(), "UTF-8");
    }
	ping = System.currentTimeMillis() - ping;
	
	json.add("statusCode", connection.getResponseCode());
	json.add("message", connection.getResponseMessage());
	json.add("body", body);
	json.add("elapsedTime", ping);
} catch (Exception e) {
	e.printStackTrace();
	json.add("statusCode", -1);
	json.add("message", e.getMessage());
} finally {
    if(connection != null){
    	connection.disconnect();
    }
}
%><%=json.toString()%>