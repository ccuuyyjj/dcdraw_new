<%@ page language="java" contentType="text/html; charset=UTF-8" import="java.util.Map, java.io.File"
    pageEncoding="UTF-8"%><%
    Map<String, String[]> queryMap = request.getParameterMap();
    boolean result = false;
	if(queryMap.containsKey("q") && !queryMap.get("q")[0].isEmpty()){
		String filename = queryMap.get("q")[0];
		if(filename.endsWith(".log")){
		File target = new File(application.getRealPath("/logs"), filename);
		if(target.exists() && target.canWrite())
			target.delete();
			result = true;
		}
	}
	if(result){
		response.sendRedirect(application.getContextPath() + "/logs");
	} else {
		response.getWriter().write("<html><head><meta http-equiv='refresh' content='3;"+request.getContextPath()+"/logs'></head><body><h1>파일 삭제 실패</h1></body></html>");
	}
%>