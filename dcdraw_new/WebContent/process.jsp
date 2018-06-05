<%@ page language="java" import="java.io.*, java.net.*, java.util.*, java.text.SimpleDateFormat, org.kopitubruk.util.json.*, dcdraw.*"
	contentType="application/json" pageEncoding="UTF-8"%><%
	response.setHeader("Cache-Control", "no-cache");
	JsonObject json = new JsonObject();
	request.setCharacterEncoding("UTF-8");
	response.setCharacterEncoding("UTF-8");
	Map<String, String[]> queryMap = request.getParameterMap();
	/*
		queryMap 구조
		url: http://gall.dcinside.com/board/view/?id=mabi_heroes&no=7823930&page=1
		popul: 1
		cut: 05/18/20/40
		no_yudong: N
		no_repeat: Y
		exception: 
		exception_ip: 
	*/
	String URL = queryMap.get("url")[0];
	int popul = Integer.parseInt(queryMap.get("popul")[0]);
	int year = Calendar.getInstance().get(Calendar.YEAR);
	Date cut = new SimpleDateFormat("yyyy MM/dd/HH/mm").parse(year + " " + queryMap.get("cut")[0]);
	boolean no_yudong = queryMap.get("no_yudong")[0].equals("Y")?true:false;
	boolean no_repeat = queryMap.get("no_repeat")[0].equals("Y")?true:false;
	String[] exception = queryMap.get("exception")[0].split("\n");
	String[] exception_id = queryMap.get("exception_id")[0].split("\n");
	String[] exception_ip = queryMap.get("exception_ip")[0].split("\n");
	String id = "(empty-id)";
	String no = "(empty-no)";
	boolean log_enabled = true;
	
	if(URL.contains("dcinside.com/")&&URL.contains("id=")&&URL.contains("no=")){
		id = URL.substring(URL.indexOf("id=")+3);
		id = id.substring(0, id.indexOf("&"));
		no = URL.substring(URL.indexOf("no=")+3);
		if(no.indexOf("&") != -1)
			no = no.substring(0, no.indexOf("&"));
		List<Comment> comment_list = CommentParser.parse(id, Integer.parseInt(no));
		
		List<String> list = new ArrayList<>();
		outerloop:
		for(int i = 0; i < comment_list.size(); i++){
			Comment c = comment_list.get(i);
			if(c.getRetime().after(cut)){
				continue;
			}
			if(c.getUser_id().startsWith("yudong:")){
				String name = c.getUser_nick() + "(" + c.getUser_id().substring(7) + ")";
				if(no_yudong){
					continue;
				}
				if(no_repeat){
					if(list.contains(name)){
						continue;
					}
				}
				if(!exception[0].isEmpty()){
					for(String ex : exception)
						if(c.getUser_nick().equals(ex.trim()))
							continue outerloop;
				}
				if(!exception_ip[0].isEmpty()){
					for(String ex : exception_ip)
						if(c.getUser_id().substring(7).equals(ex.trim()))
							continue outerloop;
				}
				list.add(name);
			} else {
				String name = c.getUser_nick() + "(" + c.getUser_id() + ")";
				if(no_repeat) {
					if(list.contains(name)){
						continue;
					}
				}
				if(!exception[0].isEmpty()){
					for(String ex : exception){
						if(c.getUser_nick().equals(ex.trim()))
							continue outerloop;
					}
				}
				if(!exception_id[0].isEmpty()){
					for(String ex : exception_id)
						if(c.getUser_id().equals(ex.trim()))
							continue outerloop;
				}
				list.add(name);
			}
		}
		
		//{"result":true,"list":"asdf, fdsf, abc","cnt":7,"winner":"asdf"}
		if(list.size() == 0){
			log_enabled = false;
			json.add("result", false);
			json.add("msg", "조건에 맞는 갤러가 아무도 음슴..;;");
		} else if(list.size() < popul) {
			log_enabled = false;
			json.add("result", false);
			json.add("msg", "조건에 맞는 갤러가 추첨수보다 적음..;;");
		} else {
			List<String> winner = new ArrayList<>();
			json.add("result", true);
			StringBuilder list_str = new StringBuilder();
			for(String s : list){
				list_str.append(s).append(", ");
			}
			json.add("list", list_str.toString().substring(0, list_str.length()-2));
			json.add("cnt", list.size());
			for(int i = 1; i <= popul; i++){
				int winner_idx = (int)(Math.random() * list.size());
				winner.add(list.get(winner_idx));
				list.remove(winner_idx);
			}
			StringBuilder winner_str = new StringBuilder();
			for(String s : winner){
				winner_str.append(s).append(", ");
			}
			json.add("winner", winner_str.toString().substring(0, winner_str.length()-2));
		}
	} else {
		log_enabled = false;
		json.add("result", false);
		json.add("msg", "url형식이 잘못되었습니다.");
	}
	/*
		url: http://gall.dcinside.com/board/view/?id=mabi_heroes&no=7823930&page=1
		popul: 1
		cut: 05/18/20/40
		no_yudong: N
		no_repeat: Y
		exception: 
		exception_ip: 
	*/
	StringBuilder sb = new StringBuilder()
		.append("Current Time : ").append(new Date().toString()).append("\r\n")
		.append("Remote IP : ").append(request.getRemoteAddr()).append("\r\n");
	
	for(String key : queryMap.keySet()){
		sb.append(key).append(" : ").append(queryMap.get(key)[0]).append("\r\n");
	}
	
	sb.append("\r\n")
	.append("Result\r\n")
	.append(json.toString());
	
	StringBuffer logname = new StringBuffer()
			.append("dcdraw_")
			.append(System.currentTimeMillis()).append("_")
			.append(id).append("_")
			.append(no).append("_")
			.append(request.getRemoteAddr().replace(".", "-").replace(":", "-"))
			.append(".log");
	
	File target = new File(application.getRealPath("/logs"), logname.toString());
	if(log_enabled && target.createNewFile()){
		FileWriter writer = new FileWriter(target);
		writer.write(sb.toString());
		writer.close();
	}
%><%=json.toString()%>