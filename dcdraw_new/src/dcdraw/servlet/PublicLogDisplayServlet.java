package dcdraw.servlet;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.TimeZone;

import org.apache.catalina.WebResource;
import org.apache.catalina.servlets.DefaultServlet;
import org.apache.tomcat.util.security.Escape;

public class PublicLogDisplayServlet extends DefaultServlet {
	/**
	 * 
	 */
	private static final long serialVersionUID = -4189376761567833222L;
	protected DateFormat dateformat = new SimpleDateFormat("E, d MMM yyyy HH:mm:ss");
	{
		TimeZone.setDefault(TimeZone.getTimeZone("Asia/Seoul"));
	}
	
	@Override
	protected InputStream renderHtml(String contextPath, WebResource resource, String encoding) throws IOException {

        // Prepare a writer to a buffered area
        ByteArrayOutputStream stream = new ByteArrayOutputStream();
        OutputStreamWriter osWriter = new OutputStreamWriter(stream, "UTF8");
        PrintWriter writer = new PrintWriter(osWriter);

        StringBuilder sb = new StringBuilder();
        
        List<String> entries = Arrays.asList(resources.list(resource.getWebappPath()));
        Collections.sort(entries);

        // rewriteUrl(contextPath) is expensive. cache result for later reuse
        String rewrittenContextPath =  rewriteUrl(contextPath);
        String directoryWebappPath = resource.getWebappPath();

        // Render the page header
        sb.append("<html>\r\n");
        sb.append("<head>\r\n");
        sb.append("<title>");
//        sb.append(sm.getString("directory.title", directoryWebappPath));
        sb.append("DCdraw 로그 확인 페이지(공개용)");
        sb.append("</title>\r\n");
        sb.append("<STYLE><!--");
        sb.append(org.apache.catalina.util.TomcatCSS.TOMCAT_CSS);
        sb.append("--></STYLE> ");
        sb.append("</head>\r\n");
        sb.append("<body>");
        sb.append("<h1>");
//        sb.append(sm.getString("directory.title", directoryWebappPath));
        sb.append("DCdraw 로그 확인 페이지(공개용)");
//
//        // Render the link to our parent (if required)
//        String parentDirectory = directoryWebappPath;
//        if (parentDirectory.endsWith("/")) {
//            parentDirectory =
//                parentDirectory.substring(0, parentDirectory.length() - 1);
//        }
//        int slash = parentDirectory.lastIndexOf('/');
//        if (slash >= 0) {
//            String parent = directoryWebappPath.substring(0, slash);
//            sb.append(" - <a href=\"");
//            sb.append(rewrittenContextPath);
//            if (parent.equals(""))
//                parent = "/";
//            sb.append(rewriteUrl(parent));
//            if (!parent.endsWith("/"))
//                sb.append("/");
//            sb.append("\">");
//            sb.append("<b>");
//            sb.append(sm.getString("directory.parent", parent));
//            sb.append("</b>");
//            sb.append("</a>");
//        }

        sb.append("</h1>");
        sb.append("<HR size=\"1\" noshade=\"noshade\">");

        sb.append("<table width=\"100%\" cellspacing=\"0\"" +
                     " cellpadding=\"5\" align=\"center\">\r\n");

        // Render the column headings
        sb.append("<tr>\r\n");
        sb.append("<td align=\"left\"><font size=\"+1\"><strong>");
//        sb.append(sm.getString("directory.filename"));
        sb.append("파일명");
        sb.append("</strong></font></td>\r\n");
        sb.append("<td align=\"center\"><font size=\"+1\"><strong>");
//        sb.append(sm.getString("directory.size"));
        sb.append("파일 크기");
        sb.append("</strong></font></td>\r\n");
        sb.append("<td align=\"right\"><font size=\"+1\"><strong>");
//        sb.append(sm.getString("directory.lastModified"));
        sb.append("수정 일자");
        sb.append("</strong></font></td>\r\n");
        sb.append("</tr>");

        boolean shade = false;
        int count = 0;
        for (String entry : entries) {
            if (entry.equalsIgnoreCase("WEB-INF") ||
                entry.equalsIgnoreCase("META-INF") ||
                entry.equalsIgnoreCase("SAFE_TO_DELETE"))
                continue;
            
            WebResource childResource =
                    resources.getResource(directoryWebappPath + entry);
            if (!childResource.exists()) {
                continue;
            }

            sb.append("<tr");
            if (shade)
                sb.append(" bgcolor=\"#eeeeee\"");
            sb.append(">\r\n");
            shade = !shade;

            sb.append("<td align=\"left\">&nbsp;&nbsp;\r\n");
            sb.append("<a href=\"");
            sb.append(rewrittenContextPath);
            sb.append(rewriteUrl(directoryWebappPath + entry));
            if (childResource.isDirectory())
                sb.append("/");
            sb.append("\"><tt>");
            sb.append(Escape.htmlElementContent(entry));
            if (childResource.isDirectory())
                sb.append("/");
            sb.append("</tt></a> ");
            sb.append("</td>\r\n");

            sb.append("<td align=\"right\"><tt>");
            if (childResource.isDirectory())
                sb.append("&nbsp;");
            else
                sb.append(renderSize(childResource.getContentLength()));
            sb.append("</tt></td>\r\n");

            sb.append("<td align=\"right\"><tt>");
            sb.append(dateformat.format(new Date(childResource.getLastModified()))).append(" KST");
            sb.append("</tt></td>\r\n");

            sb.append("</tr>\r\n");
            
            count++;
        }
        
        if(count == 0) {
        	sb.append("<tr");
            if (shade)
                sb.append(" bgcolor=\"#eeeeee\"");
            sb.append(">\r\n");
            shade = !shade;

            sb.append("<td colspan=\"3\" align=\"center\">\r\n");
            
            sb.append("<pre>로그가 음슴</pre>");
            
            sb.append("</td>\r\n");

            sb.append("</tr>\r\n");
        }

        // Render the page footer
        sb.append("</table>\r\n");

        sb.append("<HR size=\"1\" noshade=\"noshade\">");

        String readme = getReadme(resource, encoding);
        if (readme!=null) {
            sb.append(readme);
            sb.append("<HR size=\"1\" noshade=\"noshade\">");
        }

//        if (showServerInfo) {
//            sb.append("<h3>").append(ServerInfo.getServerInfo()).append("</h3>");
//        }
        
        sb.append("<h3 style='text-align: right;'><a href='javascript:history.back()'>뒤로가기</a> <a href='../logout.jsp'>로그아웃</a></h3>");
        
        sb.append("</body>\r\n");
        sb.append("</html>\r\n");

        // Return an input stream to the underlying bytes
        writer.write(sb.toString());
        writer.flush();
        return new ByteArrayInputStream(stream.toByteArray());

    }
}
