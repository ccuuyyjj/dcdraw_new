<%@ page language="java" import="java.util.*, java.io.*" contentType="text/html" pageEncoding="UTF-8"%><%
	File target = new File(application.getRealPath("/"), "recent-db");
	if(!target.exists()) target.createNewFile();
	StringBuilder winner_str = new StringBuilder();
	while(!target.canRead()){
        Thread.sleep(100);
    }
	BufferedReader reader = new BufferedReader(new FileReader(target));
	String line = reader.readLine();
    while (line != null) {
    	winner_str.append(line);
    	winner_str.append(System.lineSeparator());
        line = reader.readLine();
    }
    reader.close();%><!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="ko" xml:lang="ko">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<meta name="robots" content="nofollow" />
<link rel="shortcut icon" href="favicon.ico" type="image/x-icon">
<link rel="icon" href="favicon.ico" type="image/x-icon">
<LINK href="css.css" rel="stylesheet" type="text/css">
<script src="https://code.jquery.com/jquery-1.7.2.js"></script>
<script src="https://html2canvas.hertzen.com/dist/html2canvas.min.js"></script>
<script src="https://cdn.rawgit.com/taylorhakes/promise-polyfill/1365ba35/dist/polyfill.min.js"></script>
<script src="https://cdn.rawgit.com/rndme/download/09d6492f/download.min.js"></script>
<script src="https://www.google.com/recaptcha/api.js" async defer></script>
<script src="dcdraw.js"></script>
<title>DC추첨(Fixed)</title>
</head>

<body>
<div class="top_bar"></div>
	<div id='off-wrap'>
		<div id="header">
			<div id="socio">
				<div style="display:inline-block;float:left;">
				</div>
				<div style="font-weight:bold;display:inline-block;width:auto;">
						DC추첨(Fixed)
				</div>
				<div style="clear:both;"></div>
			</div>
			
		</div>
		<div id="form_div">
										<input type="text" name="track" class="track" id="track" placeholder="http://gall.dcinside.com/example/1234567"/><BR />
										<label class="error" for="track" id="track_error">추첨페이지 URL 입력</label><BR><BR>
					<table style="width:100%;border:0;margin:0 auto">
						<tr>
							<td style="vertical-align: top;text-align:center;border: 0 solid black;border-right-width:2px;padding:10px;">
								<h3>최근 당첨자 목록 (20명만 표시)</h3>
								<div id="recent"><%=winner_str.toString()%></div>
							</td>
							<td>
												<table style="border:0;margin:0 auto">
						<tr>
							<td style="width:130px;text-align:right;border: 0px solid black; border-right-width: 1px;padding:5px;">
								당첨자 수
							</td>
							<td style="width:75px;text-align:left;padding:5px 0px 5px 5px;">
								<input type="text" id="popul" size="3" onKeyPress="return numbersonly(event, false)"  style="ime-mode:disabled" maxlength="3" value="1"/>
							</td>
							<td style="width:130px;text-align:right;border: 0px solid black; border-right-width: 1px;padding: 5px 5px 5px 0px;">
								인원 제한 (0: 무제한)
							</td>
							<td style="text-align:left;padding:5px;">
								<input type="text" id="maxnum" size="3" onKeyPress="return numbersonly(event, false)"  style="ime-mode:disabled" maxlength="3" value="0"/>
							</td>
						</tr>
						<tr>
							<td style="text-align:right;border: 0px solid black; border-right-width: 1px;padding:5px;">
								컷
							</td>
							<td style="text-align:left;padding:5px;" colspan='3'>
					20<select name='year' id='year'>
						<option value='2017' selected="selected">17</option><option value='2018' >18</option><option value='2019' >19</option><option value='2020' >20</option><option value='2021' >21</option>					</select>년
					<select name='month' id='month'>
						<option value='01' selected="selected">01</option><option value='02' >02</option><option value='03' >03</option><option value='04' >04</option><option value='05' >05</option><option value='06' >06</option><option value='07' >07</option><option value='08' >08</option><option value='09' >09</option><option value='10' >10</option><option value='11' >11</option><option value='12' >12</option>					</select>월
					<select name='day' id='day'>
						<option value='01' selected="selected">01</option><option value='02' >02</option><option value='03' >03</option><option value='04' >04</option><option value='05' >05</option><option value='06' >06</option><option value='07' >07</option><option value='08' >08</option><option value='09' >09</option><option value='10' >10</option><option value='11' >11</option><option value='12' >12</option><option value='13' >13</option><option value='14' >14</option><option value='15' >15</option><option value='16' >16</option><option value='17' >17</option><option value='18' >18</option><option value='19' >19</option><option value='20' >20</option><option value='21' >21</option><option value='22' >22</option><option value='23' >23</option><option value='24' >24</option><option value='25' >25</option><option value='26' >26</option><option value='27' >27</option><option value='28' >28</option><option value='29' >29</option><option value='30' >30</option><option value='31' >31</option>					</select>일
					<select name='hr' id='hr'>
						<option value='00' selected="selected">00</option><option value='01' >01</option><option value='02' >02</option><option value='03' >03</option><option value='04' >04</option><option value='05' >05</option><option value='06' >06</option><option value='07' >07</option><option value='08' >08</option><option value='09' >09</option><option value='10' >10</option><option value='11' >11</option><option value='12' >12</option><option value='13' >13</option><option value='14' >14</option><option value='15' >15</option><option value='16' >16</option><option value='17' >17</option><option value='18' >18</option><option value='19' >19</option><option value='20' >20</option><option value='21' >21</option><option value='22' >22</option><option value='23' >23</option>					</select>시
					<select name='min' id='min'>
						<option value='00' selected="selected">00</option><option value='01' >01</option><option value='02' >02</option><option value='03' >03</option><option value='04' >04</option><option value='05' >05</option><option value='06' >06</option><option value='07' >07</option><option value='08' >08</option><option value='09' >09</option><option value='10' >10</option><option value='11' >11</option><option value='12' >12</option><option value='13' >13</option><option value='14' >14</option><option value='15' >15</option><option value='16' >16</option><option value='17' >17</option><option value='18' >18</option><option value='19' >19</option><option value='20' >20</option><option value='21' >21</option><option value='22' >22</option><option value='23' >23</option><option value='24' >24</option><option value='25' >25</option><option value='26' >26</option><option value='27' >27</option><option value='28' >28</option><option value='29' >29</option><option value='30' >30</option><option value='31' >31</option><option value='32' >32</option><option value='33' >33</option><option value='34' >34</option><option value='35' >35</option><option value='36' >36</option><option value='37' >37</option><option value='38' >38</option><option value='39' >39</option><option value='40' >40</option><option value='41' >41</option><option value='42' >42</option><option value='43' >43</option><option value='44' >44</option><option value='45' >45</option><option value='46' >46</option><option value='47' >47</option><option value='48' >48</option><option value='49' >49</option><option value='50' >50</option><option value='51' >51</option><option value='52' >52</option><option value='53' >53</option><option value='54' >54</option><option value='55' >55</option><option value='56' >56</option><option value='57' >57</option><option value='58' >58</option><option value='59' >59</option>					</select>분
						<BR>
						<input type="text" id="cut" style="display:none"/>
							</td>
						</tr>
						<tr>
							<td style="text-align:right;border: 0px solid black; border-right-width: 1px;padding:5px;">
								옵션
							</td>
							<td style="text-align:left;padding:5px;" colspan='3'>
								<label for="no_yudong">
									유동 제외
								</label>
								<input type="checkbox" id="no_yudong" value='1' style="vertical-align: middle;">
								
								<label for="no_redfish">
									최근 당첨자 제외
								</label>
								<input type="checkbox" id="no_redfish" value='1' style="vertical-align: middle;">
								
								<label for="testmode" style="font-weight: bold;">
									[테스트 모드]
								</label>
								<input type="checkbox" id="testmode" value='1' style="vertical-align: middle;">
							</td>
						</tr>
						<tr>
							<td style="text-align:right;border: 0px solid black; border-right-width: 1px;padding:5px;">
								제외 닉네임(정확히)
							</td>
							<td style="text-align:left;padding:5px;" colspan='3'>
                                <textarea id="exception" cols=40 rows=5 style="padding:0;text-align:left" placeholder="원활한 이용을 위해 간곡히 요청드립니다."></textarea>
							</td>
						</tr>
						<tr>
							<td style="text-align:right;border: 0px solid black; border-right-width: 1px;padding:5px;">
								제외 아이디(정확히)
							</td>
							<td style="text-align:left;padding:5px;" colspan='3'>
                                <textarea id="exception_id" cols=40 rows=5 style="padding:0;text-align:left" placeholder="시험삼아 돌시는 경우에는 꼭! 반드시!"></textarea>
							</td>
						</tr>
						<tr>
							<td style="text-align:right;border: 0px solid black; border-right-width: 1px;padding:5px;">
								제외 IP(정확히)
							</td>
							<td style="text-align:left;padding:5px;" colspan=3>
								<textarea id="exception_ip" cols=40 rows=5 style="padding:0;text-align:left" placeholder="옵션에 있는 테스트모드를 이용해주세요!!"></textarea>
							</td>
						</tr>
						<tr>
							<td style="text-align:right;border: 0px solid black; border-right-width: 1px;padding:5px;">
								스팸 방지용 reCAPTCHA
							</td>
							<td style="text-align:left;padding:5px;" colspan=3>
								<div class="g-recaptcha" data-sitekey="6LfWHZIUAAAAAISkXpt2Xe7PbgY-T_BsYICC-oBt" style="display: inline-block;"></div>
							</td>
						</tr>
						<tr>
							<td style="text-align:center;font-size:9pt;" colspan='4'>
								여러 닉네임/아이디/IP는 엔터 쳐서 구분하세요.<br>
								제외 IP는 유동도 포함할 경우에 유동에 대해서만 적용됩니다.(고닉에는 적용X)<br>
								IP 형식은 111.11같은 식으로 적어주세요.(예시: ㅇㅇ(39.7) -> 39.7))<br><br>
								<a href="public_logs/"><strong>※추첨자의 IP를 포함한 모든 추첨 기록은 전부 로그로 남습니다.<br>(★☆★이곳을 클릭하면 로그 확인 가능!!★☆★)</strong></a><br><br>
								IP 뒷자리를 포함한 로그 확인은 제작자(갤로그-<a href="http://gallog.dcinside.com/htckovsky">htckovsky</a>)에게 문의하세요.<br>
							</td>
						</tr>
						<tr>
							<td style="text-align:center;font-size:6pt;" colspan='4'>
							<a href="http://lab.vingsu.com/dcdraw/"><strong>원래 사이트(고장) 링크</strong></a>
							</td>
						</tr>
						<tr>
							<td style="text-align:center;font-size:10pt;" colspan='4'>
							<a href="https://github.com/ccuuyyjj/dcdraw_new"><strong>본 사이트의 소스코드 링크(Github)</strong></a>
							</td>
						</tr>
					</table>
							</td>
						</tr>
					</table>
						<br>
					<input type="submit" name="submit" class="button" id="button" value="" onClick="submit();return false" /><br><br>
					<strong>추첨 버튼은 제에에에에에에발 꼭꼭꼭꼭 한번씩만 눌러주세요.</strong><br>
					<strong>시험삼아 돌려보는 경우에는  꼭 테스트모드를 이용해주세요!</strong>
		<div id="for_load" style="display:none">
			<img src="img/ajax-loader.gif"><br/><br/><input type="button" value="취소" onclick="cancel()"/>
		</div>
		<div id='showtime' style="display:none">
		<hr width="100%" /><br>
		<div class="track_grey" id="list"></div><BR />
			<span class="error_grey" for="track" id="track_grey_error">탑승자(<span id="num"></span>)</span><br>
			<div class="track_red" id="result"></div><BR />
			<span class="error_red" for="track" id="track_red_error">당첨자</span><br>
			<span id="cap_btn" onClick="capture();">▶▷▶추첨 결과를 이미지로 저장(DC 업로드용)◀◁◀</span><br><br>
			<input type="submit" name="submit" class="button" value="" onClick="submit();return false" /><br>
			<span>재추첨</span>
		</div>
		</div>

	</div>
</body>
</html>
