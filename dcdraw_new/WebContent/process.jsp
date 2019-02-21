<%@ page language="java" import="java.util.regex.*, java.io.*, java.net.*, java.util.*, java.text.SimpleDateFormat, org.kopitubruk.util.json.*, dcdraw.*"
	contentType="application/json" pageEncoding="UTF-8"%><%
	response.setHeader("Cache-Control", "no-cache");
	ResourceBundle g_recaptcha_prop = ResourceBundle.getBundle("recaptcha");
	String g_recaptcha_secret = g_recaptcha_prop.getString("secret");
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
	String[] remoteiparr = request.getRemoteAddr().split("\\.");
	String URL = queryMap.get("url")[0];
	int popul = Integer.parseInt(queryMap.get("popul")[0]);
	int maxnum = Integer.parseInt(queryMap.get("maxnum")[0]);
	Date cut = new SimpleDateFormat("yyyy MM/dd/HH/mm").parse(queryMap.get("cut")[0]);
	boolean no_yudong = queryMap.get("no_yudong")[0].equals("Y")?true:false;
// 	boolean no_repeat = queryMap.get("no_repeat")[0].equals("Y")?true:false;
	boolean no_repeat = true;
	boolean no_redfish = queryMap.get("no_redfish")[0].equals("Y")?true:false;
	List<String> ex_nick_list = new ArrayList<String>(Arrays.asList(queryMap.get("exception")[0].split("\n")));
	List<String> ex_id_list = new ArrayList<String>(Arrays.asList(queryMap.get("exception_id")[0].split("\n")));
	List<String> ex_ip_list = new ArrayList<String>(Arrays.asList(queryMap.get("exception_ip")[0].split("\n")));
	String id = "(empty-id)";
	String no = "(empty-no)";
	List<String> winner = null;
	boolean log_enabled = true;
	boolean log_public_enabled = true;
	boolean test_mode = queryMap.get("testmode")[0].equals("Y")?true:false;

	if(no_redfish){
		Pattern p = Pattern.compile("\\(([^()]+)\\)<\\/a><br>");
		File target = new File(application.getRealPath("/"), "recent-db");
		if(target.exists()) {
			while(!target.canRead()){
		        Thread.sleep(100);
		    }
		    
			BufferedReader reader = new BufferedReader(new FileReader(target));
			String line = reader.readLine();
		    while (line != null) {
		    	Matcher m = p.matcher(line);
		    	if(m.find()){
		    		String str = m.group(1);
		    		if(str.matches("\\d+.\\d+"))
		    			ex_ip_list.add(str);
		    		else
		    			ex_id_list.add(str);
		    	}
		        line = reader.readLine();
		    }
		    reader.close();
		}
	}
	
	String g_recaptcha_response = queryMap.get("g-recaptcha-response")[0];
	// 토큰과 보안키를 가지고 성공 여부를 확인 함
    HttpURLConnection conn = (HttpURLConnection) new URL("https://www.google.com/recaptcha/api/siteverify").openConnection();
    String params = "secret="+ g_recaptcha_secret + "&response=" + g_recaptcha_response;
    conn.setRequestMethod("POST");
    conn.setDoOutput(true);
    DataOutputStream wr = new DataOutputStream(conn.getOutputStream());
    wr.writeBytes(params);
    wr.flush();
    wr.close();
    
    // 결과코드 확인(200 : 성공)
    int responseCode = conn.getResponseCode();
    StringBuffer responseBody = new StringBuffer();
    if (responseCode == 200) {
        
        // 데이터 추출
        BufferedInputStream bis = new BufferedInputStream(conn.getInputStream());
        BufferedReader reader = new BufferedReader(new InputStreamReader(bis));
        String line;
        while ((line = reader.readLine()) != null) {
            responseBody.append(line);
        }
        bis.close();
    }
    if(responseBody.toString().indexOf("\"success\": true") > -1){
    	if(URL.matches("^http:\\/\\/m\\.dcinside\\.com\\/board\\/\\w+\\/\\d+$")||URL.matches("^http:\\/\\/gall\\.dcinside\\.com\\/\\w+\\/\\d+$")||URL.matches("^https:\\/\\/m\\.dcinside\\.com\\/board\\/\\w+\\/\\d+$")||URL.matches("^https:\\/\\/gall\\.dcinside\\.com\\/\\w+\\/\\d+$")||(URL.contains("dcinside.com/")&&URL.contains("id=")&&URL.contains("no="))){
    		if(URL.matches("^http:\\/\\/gall\\.dcinside\\.com\\/\\w+\\/\\d+$")){
    			String[] tmp = URL.substring(25).split("\\/");
    			id = tmp[0];
    			no = tmp[1];
    		} else if(URL.matches("^http:\\/\\/m\\.dcinside\\.com\\/board\\/\\w+\\/\\d+$")){
    			String[] tmp = URL.substring(28).split("\\/");
    			id = tmp[0];
    			no = tmp[1];
    		} else if(URL.matches("^https:\\/\\/gall\\.dcinside\\.com\\/\\w+\\/\\d+$")){
    			String[] tmp = URL.substring(26).split("\\/");
    			id = tmp[0];
    			no = tmp[1];
    		} else if(URL.matches("^https:\\/\\/m\\.dcinside\\.com\\/board\\/\\w+\\/\\d+$")){
    			String[] tmp = URL.substring(29).split("\\/");
    			id = tmp[0];
    			no = tmp[1];
    		} else {
    			id = URL.substring(URL.indexOf("id=")+3);
    			id = id.substring(0, id.indexOf("&"));
    			no = URL.substring(URL.indexOf("no=")+3);
    		}
    		if(no.indexOf("&") != -1)
    			no = no.substring(0, no.indexOf("&"));
    		List<Comment> comment_list = CommentParser.parse(id, Integer.parseInt(no));
    		
    		List<String> list = new ArrayList<>();
    		outerloop:
    		for(int i = 0; i < comment_list.size(); i++){
    			Comment c = comment_list.get(i);
    			if(maxnum > 0 && list.size() >= maxnum){
    				break;
    			}
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
    				if(!ex_nick_list.get(0).isEmpty()){
    					for(String ex : ex_nick_list)
    						if(c.getUser_nick().equals(ex.trim()))
    							continue outerloop;
    				}
    				if(!ex_ip_list.get(0).isEmpty()){
    					for(String ex : ex_ip_list)
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
    				if(!ex_nick_list.get(0).isEmpty()){
    					for(String ex : ex_nick_list){
    						if(c.getUser_nick().equals(ex.trim()))
    							continue outerloop;
    					}
    				}
    				if(!ex_id_list.get(0).isEmpty()){
    					for(String ex : ex_id_list)
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
    			winner = new ArrayList<>();
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
    			if(test_mode)
    				json.add("winner", winner_str.toString().substring(0, winner_str.length()-2) + " (테스트 모드)");
    			else
    				json.add("winner", winner_str.toString().substring(0, winner_str.length()-2));
    		}
    	} else {
    		log_enabled = false;
    		json.add("result", false);
    		json.add("msg", "url형식이 잘못되었습니다.");
    	}
    } else {
		log_enabled = false;
		json.add("result", false);
		json.add("msg", "reCAPTCHA 검증에 실패했습니다.");
    }
	
	if(!test_mode){ //테스트모드에선 로그를 남기지 않음.
		/*
			url: http://gall.dcinside.com/board/view/?id=mabi_heroes&no=7823930&page=1
			popul: 1
			cut: 05/18/20/40
			no_yudong: N
			no_repeat: Y
			exception: 
			exception_ip: 
		*/
		String logdate = new Date().toString();
		StringBuilder sb = new StringBuilder()
			.append("Current Time : ").append(logdate).append("\r\n")
			.append("Remote IP : ").append(remoteiparr[0]).append(".").append(remoteiparr[1]).append(".").append(remoteiparr[2]).append(".").append(remoteiparr[3]).append("\r\n");
		StringBuilder sb_public = new StringBuilder()
				.append("Current Time : ").append(logdate).append("\r\n")
				.append("Remote IP : ").append(remoteiparr[0]).append(".").append(remoteiparr[1]).append(".*.*\r\n");
		
		for(String key : queryMap.keySet()){
			sb.append(key).append(" : ").append(queryMap.get(key)[0]).append("\r\n");
			sb_public.append(key).append(" : ").append(queryMap.get(key)[0]).append("\r\n");
		}
		
		sb.append("\r\n")
		.append("Result\r\n")
		.append(json.toString());
		sb_public.append("\r\n")
		.append("Result\r\n")
		.append(json.toString());
		
		long curtimemil = System.currentTimeMillis();
		StringBuffer logname = new StringBuffer()
				.append("dcdraw_")
				.append(curtimemil).append("_")
				.append(id).append("_")
				.append(no).append("_")
				.append(remoteiparr[0]).append("-").append(remoteiparr[1]).append("-").append(remoteiparr[2]).append("-").append(remoteiparr[3])
				.append(".log");
		StringBuffer logname_public = new StringBuffer()
				.append("dcdraw_")
				.append(curtimemil).append("_")
				.append(id).append("_")
				.append(no).append("_")
				.append(remoteiparr[0]).append("-").append(remoteiparr[1])
				.append(".log");
		
		File target = new File(application.getRealPath("/logs"), logname.toString());
		if(log_enabled && target.createNewFile()){
			FileWriter writer = new FileWriter(target);
			writer.write(sb.toString());
			writer.close();
		}
		target = new File(application.getRealPath("/public_logs"), logname_public.toString());
		if(log_enabled && log_public_enabled && target.createNewFile()){
			FileWriter writer = new FileWriter(target);
			writer.write(sb_public.toString());
			writer.close();
		}
		target = new File(application.getRealPath("/"), "recent-db");
		if(!target.exists()) target.createNewFile();
		if(log_enabled && winner != null && !winner.isEmpty()){
			int size = 0;
			
			StringBuilder winner_str = new StringBuilder();
			for(String s : winner){
				if(size < 20){
					winner_str.append("<a href=\"https://gall.dcinside.com/").append(id).append("/").append(no).append("\" target=\"_blank\">").append(s).append("</a><br>");
			    	winner_str.append(System.lineSeparator());
			    	size++;
				}
			}
	
		    while(!target.canRead()){
		        Thread.sleep(100);
		    }
		    
			BufferedReader reader = new BufferedReader(new FileReader(target));
			String line = reader.readLine();
		    while (line != null && size < 20) {
		    	winner_str.append(line);
		    	winner_str.append(System.lineSeparator());
		    	size++;
		        line = reader.readLine();
		    }
		    reader.close();
		    
		    RandomAccessFile raf = new RandomAccessFile(target, "rw");
		    raf.setLength(0);
		    raf.close();
		    
		    while(!target.canWrite()){
		        Thread.sleep(100);
		    }
		    
			FileWriter writer = new FileWriter(target);
			writer.write(winner_str.toString());
			writer.close();
		}
	}
%><%=json.toString()%>