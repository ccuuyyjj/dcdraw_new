<%@ page language="java" contentType="application/json" pageEncoding="UTF-8" import="java.util.ResourceBundle, java.net.HttpURLConnection, java.net.URL, org.kopitubruk.util.json.*, java.net.InetSocketAddress, java.net.Proxy"%><%
response.setHeader("Cache-Control", "no-cache");
/*
	WEB-INF/classes 디렉토리 내에 proxy.properties 파일이 있어야함.
	(작성 예시)
	address=211.244.225.195
	port=3128
*/
ResourceBundle prop = ResourceBundle.getBundle("proxy");
JsonObject json = new JsonObject();
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
HttpURLConnection connection = null;
try{
	URL url = new URL("http://gall.dcinside.com/");
	Proxy proxy = new Proxy(Proxy.Type.HTTP, new InetSocketAddress(prop.getString("address"), Integer.parseInt(prop.getString("port"))));
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