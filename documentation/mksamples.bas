#
# Export samples from the code library: http://smallbasic.sourceforge.net/?q=node/9
#
# 1. import site data into mysql
#   mysql -u <username> -p -h localhost smallbasic < backup_xxx.sql
#
# 2. export from mysql:
#
# select pn.title as folder, n.title as filename, n.nid as node, fdb.body_value as code
# from 
#  d7_field_data_body as fdb 
#     left join d7_node as n on n.nid = fdb.entity_id,
#  d7_node as pn
# where n.title like '%.bas'
#  and pn.nid = (select nid from d7_book
#    where mlid = (
#     select plid from d7_menu_links as m
#     join d7_book as cb on cb.mlid = m.mlid
#     where cb.nid = fdb.entity_id))
# order by pn.title, n.title
#
# 3. Select the JSON export format from mysql-workbench
#

split trim(command), " ", args
tload args(0), in_str, 1

# cleanup the mysql json
in_str = translate(in_str, "\'", "'")
in_str = translate(in_str, "'folder' :", "\"folder\":")
in_str = translate(in_str, "'filename' :", "\"filename\":")
in_str = translate(in_str, "'code' :", "\"code\":")
in_str = translate(in_str, "'node' :", "\"node\":")
in_map = array(in_str)

mk_files("samples")

func update_code(code)
  local i, c1,c2

  c1 = instr(code, "<code>")
  c2 = instr(code, "</code>")
  if (c1 != 0 && c2 != 0) then
    code = mid(code, c1 + 6, c2 - c1 - 6)
    code = translate(code, "\r\n", chr(10))
    code = translate(code, "\\\"", "\"")
    code = translate(code, "\\\\", "\\")
  endif
  update_code = code
end

sub mk_files(prefix)
  local in_map_len = len(in_map) - 1
  local folder, filename, node, code, file_index, html, file

  file_index = {}
  if (!exist(prefix)) then
    mkdir prefix
  endif

  if (!exist(prefix + "/node")) then
    mkdir prefix + "/node"
  endif

  for i = 0 to in_map_len
    folder = prefix + "/" + translate(lower(in_map(i).folder), "/", " ")
    filename = folder + "/" + lower(in_map(i).filename)
    file_index[folder] << filename
    code = update_code(in_map(i).code)
    if (!exist(folder)) then
      mkdir folder
    endif
    tsave filename, code
    tsave prefix + "/node/" + in_map(i).node + ".bas", code
  next i

  for folder in file_index
    html = ""
    for filename in file_index[folder]
      file = rightoflast(filename, "/")
      html += "<a href='" + file + "'>" + file + "</a><br/>"
    next filename
    tsave folder + "/index.html", html
  next folder

  html = ""
  for folder in file_index
    file = rightoflast(folder, "/")
    html += "<a href='" + file + "/index.html'>" + file + "</a><br/>"
  next folder
  tsave prefix + "/index.html", html

end
