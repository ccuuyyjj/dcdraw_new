<%@ page language="java" contentType="application/json" pageEncoding="UTF-8" import="java.net.HttpURLConnection, java.net.URL, org.kopitubruk.util.json.*, java.net.InetSocketAddress, java.net.Proxy"%><%
response.setHeader("Cache-Control", "no-cache");
JsonObject json = new JsonObject();
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
HttpURLConnection connection = null;
try{
	URL url = new URL("http://gall.dcinside.com/");
	Proxy proxy = new Proxy(Proxy.Type.HTTP, new InetSocketAddress("119.196.18.51", 8080));
	connection = (HttpURLConnection) url.openConnection(proxy);
	connection.setRequestMethod("HEAD");
	connection.setConnectTimeout(5000);
	long ping = System.currentTimeMillis();
	connection.connect();
	ping = System.currentTimeMillis() - ping;
	
	json.add("statusCode", connection.getResponseCode());
	json.add("message", connection.getResponseMessage());
	json.add("ping", ping);
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