package dcdraw;

import java.io.IOException;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

import org.jsoup.Connection;
import org.jsoup.Connection.Response;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

public class CommentParser {
	private static DateFormat dateFormat = new SimpleDateFormat("yyyy.MM.dd HH:mm:ss");
	public static List<Comment> parse(String id, int no) throws IOException, ParseException {
		String userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36";
		String URL = "http://gall.dcinside.com/board/comment_view/?id="+id+"&no="+no;
		Response response = Jsoup.connect(URL)	//토큰받는용도
				.userAgent(userAgent)
                .header("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8")
                .header("Content-Type", "application/x-www-form-urlencoded")
                .header("Accept-Encoding", "gzip, deflate, br")
                .header("Accept-Language", "ko-KR,ko;q=0.8,en-US;q=0.6,en;q=0.4")
                .method(Connection.Method.GET)
                .execute();
		Map<String, String> cookie = response.cookies();
		String csrf_token = cookie.get("ci_c");
		
		response = Jsoup.connect("http://gall.dcinside.com/comment/count")	//댓글수 확인
				.userAgent(userAgent)
				.cookies(cookie)
				.header("X-Requested-With", "XMLHttpRequest")
				.data("ci_t", csrf_token)
				.data("id", id)
				.data("no", Integer.toString(no))
				.method(Connection.Method.POST)
				.execute();
		int count = Integer.parseInt(response.body());
		int page_count = count / 100 + 1;

		List<Comment> list = new ArrayList<>();
		for(int page = 1; page <= page_count; page++) {
			response = Jsoup.connect("http://gall.dcinside.com/comment/view")
				.userAgent(userAgent)
				.cookies(cookie)
				.header("X-Requested-With", "XMLHttpRequest")
				.data("ci_t", csrf_token)
				.data("id", id)
				.data("no", Integer.toString(no))
				.data("comment_page", Integer.toString(page))
				.method(Connection.Method.POST)
				.execute();
			Document doc = response.parse();
			Elements list_comment = doc.select("tr.reply_line");
			for(Element e : list_comment) {
				if(e.hasClass("comment_mandu")) continue;
				String user_nick = e.select("td.user").attr("user_name");
				String user_id = e.select("td.user").attr("user_id");
				if(user_id.isEmpty()) user_id = "yudong:" + e.select("span.etc_ip").text();
				String time = e.select("td.retime").text();
				Date retime = dateFormat.parse(time);
				Comment comment = new Comment(user_nick, user_id, retime);
				list.add(comment);
			}
		}
		
		return list;
	}
}
