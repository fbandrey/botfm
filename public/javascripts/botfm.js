function move_to_dj(dj_id){
  all_djs = dj_names.size();
  my_index = dj_names.keys().indexOf(String(dj_id));
  slider4.setValue(my_index/all_djs);
  //my_value = my_index/all_djs;
  //setTimeout('chechevica('+my_value+', 10)', 50);
}

// Ручной slow scrolling :)
function chechevica(res, num){
  cur_pos = res > slider4.value ? (res - num*10) : (res + num*10)
  //alert(cur_pos);
  slider4.setValue(cur_pos);
  if (num > 0) {
    setTimeout('chechevica('+my_value+', '+(num-1)+')', 50);
  }
}

function play_next_track(){
  // Если еще есть треки
  if (tracks_mass.length > 0){
    // Если плейлист заканчивается - загружаем новую порцию
    if (tracks_mass.length <= 2){
      get_new_tracks(0, true);
    }else{
      play_now(get_next_track());
    }
  }else{
    alert("Ошибка! Нет музыкального контента");
  }
}

function play_this_dj(dj_id){
  current_dj = dj_id;
  tracks_mass = [];

  if (dj_id == 'main'){
    content  = "<div style='float:left; margin-right:10px;'>В эфире BOT.FM</div>";
  }else{
    content  = "<div style='float:left; margin-right:10px;'>В эфире <a href='#' onClick='move_to_dj("+current_dj+"); return false;'>DJ " + dj_names.get(current_dj) + "</a></div>";
  }
  content += "<div id='refresh' style='float:left;'><a href='#' onmouseover=\"MM_swapImage('refresh_button','','/images/refresh_h.png',1)\" onmouseout=\"MM_swapImgRestore()\" onClick='play_next_track(); return false;'><img id='refresh_button' title='Пропустить' src='/images/refresh.png' style='border:0;' /></a></div><div style='clear:both;'></div>";

  $("help_content_div").innerHTML = content;
  get_new_tracks(0, true);
}

function get_next_track(){
  current_track = "";
  if (tracks_mass.length > 0){
    if (tracks_mass.length > 1){
        current_track = tracks_mass.shift();
    }else{
        current_track = tracks_mass;
        tracks_mass = [];
    }
  }
  return current_track;
}

function toggleButton(num){
  //num = parseInt(ind);
  //if (num > 0){
    if (current_dj && current_dj != num){
      soundManager.destroySound('Player'+current_dj);
      stopAllDjs();
      $('play_button_'+num).src = "/images/bot_pause.gif";
      play_this_dj(num);
    }else if (current_dj == num){
      stopAllDjs();
      current_dj = null;
      soundManager.stopAll();
    }else{
      $('play_button_'+num).src = "/images/bot_pause_hover.gif";
      play_this_dj(num);
    }
  //}else if (ind == 'main'){
  //  soundManager.destroySound('Player'+current_dj);
  //  stopAllDjs();
  //  $('play_button_'+num).src = "/images/bot_pause.gif";
  //  play_this_dj(num);
  //}
}

function highlightButton(user_id, light){
  play_file_path = light ? "/images/bot_play_hover.gif" : "/images/bot_play.gif";
  pause_file_path = light ? "/images/bot_pause_hover.gif" : "/images/bot_pause.gif";

  if (current_dj == user_id){
    $("play_button_"+user_id).src = pause_file_path;
  }else{
    $("play_button_"+user_id).src = play_file_path;
  }
}
