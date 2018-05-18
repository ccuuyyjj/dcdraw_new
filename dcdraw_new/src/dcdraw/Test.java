package dcdraw;

import java.io.IOException;
import java.text.ParseException;
import java.util.List;

public class Test {
	public static void main(String[] args) throws IOException, ParseException {
		String URL = "http://gall.dcinside.com/board/view/?id=mabi_heroes&no=7823930&page=1";
		String id = URL.substring(URL.indexOf("id=")+3);
		id = id.substring(0, id.indexOf("&"));
		String no = URL.substring(URL.indexOf("no=")+3);
		no = no.substring(0, no.indexOf("&"));
		List<Comment> list = CommentParser.parse(id, Integer.parseInt(no));
		for(Comment comment : list) {
			System.out.println(comment);
		}
		System.out.println("total : " + list.size());
	}
}
