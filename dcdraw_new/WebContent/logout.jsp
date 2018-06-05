<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" session="true"%><%
	session.invalidate();
	response.setStatus(401);
	response.getWriter().write("<html><head><meta http-equiv='refresh' content='0;"+request.getContextPath()+"'></head></html>");
%>