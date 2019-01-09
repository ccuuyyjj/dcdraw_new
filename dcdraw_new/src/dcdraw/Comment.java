package dcdraw;

import java.util.Date;

public class Comment implements Comparable<Comment> {
	private String user_nick;
	private String user_id;
	private Date retime;
	public Comment(String user_nick, String user_id, Date retime) {
		super();
		this.user_nick = user_nick;
		this.user_id = user_id;
		this.retime = retime;
	}
	public String getUser_nick() {
		return user_nick;
	}
	public void setUser_nick(String user_nick) {
		this.user_nick = user_nick;
	}
	public String getUser_id() {
		return user_id;
	}
	public void setUser_id(String user_id) {
		this.user_id = user_id;
	}
	public Date getRetime() {
		return retime;
	}
	public void setRetime(Date retime) {
		this.retime = retime;
	}
	@Override
	public String toString() {
		return "Comment [user_nick=" + user_nick + ", user_id=" + user_id + ", retime=" + retime + "]";
	}
	@Override
	public int compareTo(Comment o) {
		return retime.compareTo(o.getRetime());
	}
}
