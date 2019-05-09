package dcdraw;

import java.io.IOException;
import java.net.Proxy;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.jsoup.Connection;
import org.jsoup.Connection.Response;
import org.jsoup.HttpStatusException;
import org.jsoup.Jsoup;
import org.kopitubruk.util.json.JSONParser;

public class CommentParser {
	private static DateFormat dateFormat = new SimpleDateFormat("yyyy.MM.dd HH:mm:ss");
//	private static DateFormat dateFormat = new SimpleDateFormat("MM.dd HH:mm:ss");

	@SuppressWarnings("unchecked")
	public static List<Comment> parse(String id, int no) throws IOException, ParseException, InterruptedException {
		String userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36";
		String URL = "https://gall.dcinside.com/board/comment_view/?id=" + id + "&no=" + no;
		List<Comment> list = new ArrayList<>();
		Response response = null;

		int trycount = 0;
		int maxTries = 3;
		while (true) {
			try {
				response = Jsoup.connect(URL) // 토큰받는용도
						.userAgent(userAgent)
						.header("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8")
						.header("Content-Type", "application/x-www-form-urlencoded")
						.header("Accept-Encoding", "gzip, deflate, br")
						.header("Accept-Language", "ko-KR,ko;q=0.8,en-US;q=0.6,en;q=0.4")
						.method(Connection.Method.GET)
						.execute();
				if (response.statusCode() == 200)
					break;
				else
					throw new HttpStatusException("아무튼200이 아님", response.statusCode(), response.url().toString());
			} catch (HttpStatusException e) {
				Thread.sleep(500);
				if (++trycount == maxTries)
					throw e;
			}
		}

		Map<String, String> cookie = response.cookies();
		//String csrf_token = cookie.get("ci_c");
		String e_s_n_o = response.parse().select("#e_s_n_o").val();

		trycount = 0;
		int page = 1;
		while (true) {
			try {
				response = Jsoup.connect("https://gall.dcinside.com/board/comment/")
						.userAgent(userAgent)
						.cookies(cookie)
						.header("X-Requested-With", "XMLHttpRequest")
						//.data("ci_t", csrf_token)
						.data("id", id)
						.data("no", Integer.toString(no))
						.data("cmt_id", id)
						.data("cmt_no", Integer.toString(no))
						.data("e_s_n_o", e_s_n_o)
						.data("comment_page", Integer.toString(page))
						.method(Connection.Method.POST).execute();
				if (response.statusCode() == 200)
					break;
				else
					throw new HttpStatusException("아무튼200이 아님", response.statusCode(), response.url().toString());
			} catch (HttpStatusException e) {
				Thread.sleep(500);
				if (++trycount == maxTries)
					throw e;
			}
		}

		LinkedHashMap<String, Object> json = (LinkedHashMap<String, Object>) JSONParser.parseJSON(response.body());
		int total_cnt = Integer.parseInt(json.get("total_cnt").toString());
		int comment_cnt = Integer.parseInt(json.get("comment_cnt").toString());
		ArrayList<LinkedHashMap<String, Object>> comments = (ArrayList<LinkedHashMap<String, Object>>) json
				.get("comments");
		for (LinkedHashMap<String, Object> cmt : comments) {
			if (cmt.get("nicktype").equals("COMMENT_BOY") || cmt.get("is_delete").equals("1"))
				continue;
			if (Integer.parseInt(cmt.get("depth").toString()) > 0)
				comment_cnt++;
			String user_nick = cmt.get("name").toString();
			if (user_nick.isEmpty())
				user_nick = "[공백]";
			String user_id = cmt.get("user_id").toString();
			if (user_id.isEmpty())
				user_id = "yudong:" + cmt.get("ip").toString();
			String time = cmt.get("reg_date").toString(); // 올해 작성되지 않은 댓글들은 년도부터 붙어서 나옴 
			if (time.length() < 15) time = Calendar.getInstance().get(Calendar.YEAR) + "." + time; // 올해 작성된 댓글 날짜 저장용
			Date retime = dateFormat.parse(time);
			Comment comment = new Comment(user_nick.trim(), user_id.trim(), retime);
			list.add(comment);
		}

		while (total_cnt > comment_cnt) {
			trycount = 0;
			page++;
			while (true) {
				try {
					response = Jsoup.connect("https://gall.dcinside.com/board/comment/")
							.userAgent(userAgent)
							.cookies(cookie)
							.header("X-Requested-With", "XMLHttpRequest")
//							.data("ci_t", csrf_token)
							.data("id", id)
							.data("no", Integer.toString(no))
							.data("cmt_id", id)
							.data("cmt_no", Integer.toString(no))
							.data("e_s_n_o", e_s_n_o)
							.data("comment_page", Integer.toString(page))
							.method(Connection.Method.POST).execute();
					if (response.statusCode() == 200)
						break;
					else
						throw new HttpStatusException("아무튼200이 아님", response.statusCode(), response.url().toString());
				} catch (HttpStatusException e) {
					Thread.sleep(500);
					if (++trycount == maxTries)
						throw e;
				}
			}

			json = (LinkedHashMap<String, Object>) JSONParser.parseJSON(response.body());
			comment_cnt += Integer.parseInt(json.get("comment_cnt").toString());
			comments = (ArrayList<LinkedHashMap<String, Object>>) json.get("comments");
			for (LinkedHashMap<String, Object> cmt : comments) {
				if (cmt.get("nicktype").equals("COMMENT_BOY"))
					continue;
				if (Integer.parseInt(cmt.get("depth").toString()) > 0)
					comment_cnt++;
				String user_nick = cmt.get("name").toString();
				if (user_nick.isEmpty())
					user_nick = "[공백]";
				String user_id = cmt.get("user_id").toString();
				if (user_id.isEmpty())
					user_id = "yudong:" + cmt.get("ip").toString();
				String time = cmt.get("reg_date").toString(); // 올해 작성되지 않은 댓글들은 년도부터 붙어서 나옴 
				if (time.length() < 15) time = Calendar.getInstance().get(Calendar.YEAR) + "." + time; // 올해 작성된 댓글 날짜 저장용
				Date retime = dateFormat.parse(time);
				Comment comment = new Comment(user_nick.trim(), user_id.trim(), retime);
				list.add(comment);
			}
		}
		Collections.sort(list);
		return list;
	}
	
	@SuppressWarnings("unchecked")
	public static List<Comment> parse_alt(String id, int no, Proxy proxy) throws IOException, ParseException, InterruptedException {
		String userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36";
		String URL = "https://gall.dcinside.com/board/comment_view/?id=" + id + "&no=" + no;
		List<Comment> list = new ArrayList<>();
		Response response = null;

		int trycount = 0;
		int maxTries = 3;
		while (true) {
			try {
				response = Jsoup.connect(URL) // 토큰받는용도
						.proxy(proxy)
						.userAgent(userAgent)
						.header("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8")
						.header("Content-Type", "application/x-www-form-urlencoded")
						.header("Accept-Encoding", "gzip, deflate, br")
						.header("Accept-Language", "ko-KR,ko;q=0.8,en-US;q=0.6,en;q=0.4")
						.method(Connection.Method.GET)
						.execute();
				if (response.statusCode() == 200)
					break;
				else
					throw new HttpStatusException("아무튼200이 아님", response.statusCode(), response.url().toString());
			} catch (HttpStatusException e) {
				Thread.sleep(500);
				if (++trycount == maxTries)
					throw e;
			}
		}

		Map<String, String> cookie = response.cookies();
		//String csrf_token = cookie.get("ci_c");
		String e_s_n_o = response.parse().select("#e_s_n_o").val();

		trycount = 0;
		int page = 1;
		while (true) {
			try {
				response = Jsoup.connect("https://gall.dcinside.com/board/comment/")
						.proxy(proxy)
						.userAgent(userAgent)
						.cookies(cookie)
						.header("X-Requested-With", "XMLHttpRequest")
						//.data("ci_t", csrf_token)
						.data("id", id)
						.data("no", Integer.toString(no))
						.data("cmt_id", id)
						.data("cmt_no", Integer.toString(no))
						.data("e_s_n_o", e_s_n_o)
						.data("comment_page", Integer.toString(page))
						.method(Connection.Method.POST).execute();
				if (response.statusCode() == 200)
					break;
				else
					throw new HttpStatusException("아무튼200이 아님", response.statusCode(), response.url().toString());
			} catch (HttpStatusException e) {
				Thread.sleep(500);
				if (++trycount == maxTries)
					throw e;
			}
		}

		LinkedHashMap<String, Object> json = (LinkedHashMap<String, Object>) JSONParser.parseJSON(response.body());
		int total_cnt = Integer.parseInt(json.get("total_cnt").toString());
		int comment_cnt = Integer.parseInt(json.get("comment_cnt").toString());
		ArrayList<LinkedHashMap<String, Object>> comments = (ArrayList<LinkedHashMap<String, Object>>) json
				.get("comments");
		for (LinkedHashMap<String, Object> cmt : comments) {
			if (cmt.get("nicktype").equals("COMMENT_BOY") || cmt.get("is_delete").equals("1"))
				continue;
			if (Integer.parseInt(cmt.get("depth").toString()) > 0)
				comment_cnt++;
			String user_nick = cmt.get("name").toString();
			if (user_nick.isEmpty())
				user_nick = "[공백]";
			String user_id = cmt.get("user_id").toString();
			if (user_id.isEmpty())
				user_id = "yudong:" + cmt.get("ip").toString();
			String time = cmt.get("reg_date").toString(); // 올해 작성되지 않은 댓글들은 년도부터 붙어서 나옴 
			if (time.length() < 15) time = Calendar.getInstance().get(Calendar.YEAR) + "." + time; // 올해 작성된 댓글 날짜 저장용
			Date retime = dateFormat.parse(time);
			Comment comment = new Comment(user_nick.trim(), user_id.trim(), retime);
			list.add(comment);
		}

		while (total_cnt > comment_cnt) {
			trycount = 0;
			page++;
			while (true) {
				try {
					response = Jsoup.connect("https://gall.dcinside.com/board/comment/")
							.proxy(proxy)
							.userAgent(userAgent)
							.cookies(cookie)
							.header("X-Requested-With", "XMLHttpRequest")
//							.data("ci_t", csrf_token)
							.data("id", id)
							.data("no", Integer.toString(no))
							.data("cmt_id", id)
							.data("cmt_no", Integer.toString(no))
							.data("e_s_n_o", e_s_n_o)
							.data("comment_page", Integer.toString(page))
							.method(Connection.Method.POST).execute();
					if (response.statusCode() == 200)
						break;
					else
						throw new HttpStatusException("아무튼200이 아님", response.statusCode(), response.url().toString());
				} catch (HttpStatusException e) {
					Thread.sleep(500);
					if (++trycount == maxTries)
						throw e;
				}
			}

			json = (LinkedHashMap<String, Object>) JSONParser.parseJSON(response.body());
			comment_cnt += Integer.parseInt(json.get("comment_cnt").toString());
			comments = (ArrayList<LinkedHashMap<String, Object>>) json.get("comments");
			for (LinkedHashMap<String, Object> cmt : comments) {
				if (cmt.get("nicktype").equals("COMMENT_BOY"))
					continue;
				if (Integer.parseInt(cmt.get("depth").toString()) > 0)
					comment_cnt++;
				String user_nick = cmt.get("name").toString();
				if (user_nick.isEmpty())
					user_nick = "[공백]";
				String user_id = cmt.get("user_id").toString();
				if (user_id.isEmpty())
					user_id = "yudong:" + cmt.get("ip").toString();
				String time = cmt.get("reg_date").toString(); // 올해 작성되지 않은 댓글들은 년도부터 붙어서 나옴 
				if (time.length() < 15) time = Calendar.getInstance().get(Calendar.YEAR) + "." + time; // 올해 작성된 댓글 날짜 저장용
				Date retime = dateFormat.parse(time);
				Comment comment = new Comment(user_nick.trim(), user_id.trim(), retime);
				list.add(comment);
			}
		}

		Collections.sort(list);
		return list;
	}

//	public static void main(String[] args) throws IOException, ParseException, InterruptedException {
//		System.out.println(CommentParser.parse("mabi_heroes", 8055502).size());
//	}
}
