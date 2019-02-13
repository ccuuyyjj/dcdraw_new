//Submit
function submit() {
	$('#for_load').attr("style", "display:;");
	$('#button').attr("style", "display:none");
	$('#showtime').attr("style", "display:none;");
	$.ajax({
        url:'con_test.jsp',
        dataType:'json',
        type:'POST',
        success:function(result){
            if(result['statusCode']==200){
            	document.getElementById("cut").value = year.options[year.selectedIndex].value+' '+month.options[month.selectedIndex].value+'/'+day.options[day.selectedIndex].value+'/'+hr.options[hr.selectedIndex].value+'/'+min.options[min.selectedIndex].value
            	if($("input:checkbox[id='no_yudong']").is(":checked")) no_yudong = 'Y';
            	else no_yudong = 'N';
            	if($("input:checkbox[id='no_redfish']").is(":checked")) no_redfish = 'Y';
            	else no_redfish= 'N';
            	$.ajax({
                    url:'process.jsp',
                    dataType:'json',
                    type:'POST',
                    data:{
            			'url':$(track).val(),
            			'popul':$(popul).val(),
            			'maxnum':$(maxnum).val(),
            			'cut':$(cut).val(),
            			'no_yudong':no_yudong,
            			'no_redfish':no_redfish,
            			'exception':$('textarea#exception').val(),
            			'exception_id':$('textarea#exception_id').val(),
            			'exception_ip':$('textarea#exception_ip').val()
            		},
                    success:function(result){
                        if(result['result']==true){
            				$('#result').html(result['winner']);
            				$('#list').html(result['list']);
            				$('#num').html(result['cnt']+'명');
            				$('#showtime').attr("style", "display:;");
            				$('#for_load').attr("style", "display:none;");
            				var iframe = document.getElementById('recent-list');
            				iframe.src = iframe.src;
            			}
            			if(result['result']!==true){
            				$('#for_load').attr("style", "display:none;");
            				$('#button').attr("style", "display:;");
            				alert(result['msg']);
            			}
                    },
                    error:function(error) {
	                    	$('#for_load').attr("style", "display:none;");
	        				$('#button').attr("style", "display:;");
	            			alert("에러 발생! 문제가 계속 발생 시 제작자에게 문의주세요!");
                        }
            	});
			} else {
				$.ajax({
			        url:'con_test_alt.jsp',
			        dataType:'json',
			        type:'POST',
			        success:function(result){
			            if(result['statusCode']==200){
			            	document.getElementById("cut").value = year.options[year.selectedIndex].value+' '+month.options[month.selectedIndex].value+'/'+day.options[day.selectedIndex].value+'/'+hr.options[hr.selectedIndex].value+'/'+min.options[min.selectedIndex].value
			            	if($("input:checkbox[id='no_yudong']").is(":checked")) no_yudong = 'Y';
			            	else no_yudong = 'N';
			            	if($("input:checkbox[id='no_redfish']").is(":checked")) no_redfish = 'Y';
			            	else no_redfish= 'N';
			            	$.ajax({
			                    url:'process_alt.jsp',
			                    dataType:'json',
			                    type:'POST',
			                    data:{
			            			'url':$(track).val(),
			            			'popul':$(popul).val(),
			            			'maxnum':$(maxnum).val(),
			            			'cut':$(cut).val(),
			            			'no_yudong':no_yudong,
			            			'no_redfish':no_redfish,
			            			'exception':$('textarea#exception').val(),
			            			'exception_id':$('textarea#exception_id').val(),
			            			'exception_ip':$('textarea#exception_ip').val()
			            		},
			                    success:function(result){
			                        if(result['result']==true){
			            				$('#result').html(result['winner']);
			            				$('#list').html(result['list']);
			            				$('#num').html(result['cnt']+'명');
			            				$('#showtime').attr("style", "display:;");
			            				$('#for_load').attr("style", "display:none;");
			            				var iframe = document.getElementById('recent-list');
			            				iframe.src = iframe.src;
			            			}
			            			if(result['result']!==true){
			            				$('#for_load').attr("style", "display:none;");
			            				$('#button').attr("style", "display:;");
			            				alert(result['msg']);
			            			}
			                    },
			                    error:function(error) {
			                    	$('#for_load').attr("style", "display:none;");
			        				$('#button').attr("style", "display:;");
			            			alert("에러 발생! 문제가 계속 발생 시 제작자에게 문의주세요!");
			                        }
			            	});
						} else {
							$('#for_load').attr("style", "display:none;");
							$('#button').attr("style", "display:;");
			            	alert("현재 추첨기 서버(미국 서부에 위치함)에서 디시인사이드 댓글 서버에 접근이 불가능하여 탑승자 목록 불러오기에 실패했습니다.\n디시인사이드 측에서 DDOS 공격 방어등의 이유로 해외 접속을 임시 차단해놓았을 수 있으니 자정 이후에 다시 시도해보세요.");
			            }
			        }
			    });
            }
        }
    });
}


function cancel(){
    $('#for_load').attr("style", "display:none;");
    $('#button').attr("style", "display:;");
    $('#showtime').attr("style", "display:none;");
}

function numbersonly(e, decimal) {
    var key;
    var keychar;

    if (window.event) {
        key = window.event.keyCode;
    } else if (e) {
        key = e.which;
    } else {
        return true;
    }
    keychar = String.fromCharCode(key);

    if ((key == null) || (key == 0) || (key == 8) || (key == 9) || (key == 13)
            || (key == 27)) {
        return true;
    } else if ((("0123456789").indexOf(keychar) > -1)) {
        return true;
    } else if (decimal && (keychar == ".")) {
        return true;
    } else
        return false;
}
function capture(){
	html2canvas(document.querySelector("#off-wrap")).then(function(canvas){
		download(canvas.toDataURL('image/png'),'dcdraw'+Date.now()+'.png');
	});
}
$(document).ready(function(){
  var dt = new Date();
  var year = dt.getYear() + 1900;
  var month = dt.getMonth();
  var day = dt.getDate() - 1;
  var hr = dt.getHours();
  var min = dt.getMinutes();
  $("#year").val(year);
  $("#month").val($("#month").children().eq(month).text());
  $("#day").val($("#day").children().eq(day).text());
  $("#hr").val($("#hr").children().eq(hr).text());
  $("#min").val($("#min").children().eq(min).text());
});