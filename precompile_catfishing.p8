pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
function get_active_menu()
  for menu in all(menus) do
    if (menu.enable) return menu
  end
end
function get_menu(name)
  for menu in all(menus) do
    if (menu.name == name) return menu
  end
end
function swap_menu_context(name)
  get_active_menu().enable = false
  if (name == nil) return
  get_menu(name).enable = true
end
function longest_menu_str(data)
  local len = 0
  for str in all(data) do
    len = max(len, #str.text)
  end
  return len
end
function load_area(area_id)
  get_active_menu().enable = false
  loaded_area = area_id 
  if area_id > 0 then 
    FishingArea.reset(global_data_table.areas[loaded_area])
    if area_id == 1 then 
      reload(0x0,0x0,0x2000)
    else
      load_stored_gfx(map_table[loaded_area-1])
    end
  elseif area_id == 0 then 
    load_stored_gfx(shop_sprite_sheet)
  else 
    reload(0x0,0x0,0x2000)
  end
end
function load_area_state(name, id)
  if (id < 1) reload(0x0,0x0,0x2000)
  if id == -3 then 
    reset()
  else
    swap_menu_context(name)
    if (loaded_area > 0) FishingArea.reset(global_data_table.areas[loaded_area])   
    loaded_area = id
  end
end
function parse_menu_content(data)
  if type(data) == "string" then
    return _ENV[data]()
  else
    local content = {}
    for dat in all(data) do 
      add(content, {
        text = dat.text,
        color = dat.color or {7, 0},
        callback = _ENV[dat.callback],
        args = dat.args
      })
    end
    return content
  end
end
function sell_all_fish()
  if (#fish_inventory > 0) sfx(6)
  for fish in all(fish_inventory) do 
    local weight, size, rarity = unpack(fish)
    cash += 
      flr((weight * global_data_table.sell_weights.per_weight_unit + 
      size * global_data_table.sell_weights.per_size_unit) * rarity)
    del(fish_inventory, fish)
  end
end
function switch_rods_menu()
  local menu_list = {}
  for index, rod in pairs(rod_inventory) do
    add(menu_list, {
      text=rod.name.." (p "..rod.power..")",
      color={7,0},
      callback=select_rod,
      args={index}
    })
  end
  return menu_list
end
function display_rod_selection_icon(pos)
  local border_rect = BorderRect:new(
    Vec:new(4, 44),
    Vec:new(18,18),
    7, (current_rod == rod_inventory[pos]) and 15 or 0, 2)
  BorderRect.draw(border_rect)
    
  spr(rod_inventory[pos].spriteID, 7, 46, 2, 2)
end
function select_rod(index)
  current_rod = rod_inventory[index]
end
function enable_rod_shop()
  show_rod_shop = true
end
function save_and_quit()
  save()
  load_area_state("title", -3)
end
function save()
  local address = 0x5e00
  address = save_byte2(address, cash)
  address = save_byte(address, encode_rod_inventory())
  for i, rod in pairs(rod_inventory) do 
    if rod.name == current_rod.name then 
      address = save_byte(address, i)
      break
    end
  end
  local fishes = Inventory.get_data(fishpedia)
  address = save_byte(address, #fishes)
  for fish_data in all(fishes) do 
    address = save_byte(address, fish_data.id)
    address = save_byte2(address, round_to(fish_data.data.weight * 100))
    address = save_byte2(address, round_to(fish_data.data.size * 100))
  end
end
function load()
  local address = 0x5e00
  local cash, rods = 0, {}
  cash = %address
  address += 2
  rods = decode_rod_inventory(@address)
  address += 1
  local selected_rod_id = @address
  address += 1
  local fish_count = @address
  address += 1
  for i=1, fish_count do 
    local id = @address 
    address += 1
    local weight_ = %address
    address += 2
    local size_ = %address
    address += 2
    local entry = Inventory.get_entry(fishpedia, id)
    entry.data = {
      description=entry.data.description,
      weight=weight_ / 100,
      size=size_ / 100,
      units=entry.data.units,
      rarity = entry.data.rarity
    }
    entry.is_hidden = false
  end
  for rod in all(rods) do 
    add(rod_inventory, rod)
  end
  select_rod(selected_rod_id)
  Menu.update_content(get_menu("switch_rods"), switch_rods_menu())
  load_area_state("main", -1)
end
global_data_str="palettes={transparent_color_id=0,menu={4,7,7,3}},credit_offsets={30,45,70,95,120,145,170,195,220,250,270,295,315},menu_data={{name=title,position={34,70},content={{text=new game,callback=load_area_state,args={main,-1}},{text=load game,callback=load},{text=credits,callback=load_area,args={-4}}}},{name=main,position={5,70},content={{text=shop,callback=load_area,args={0}},{text=fishing,callback=swap_menu_context,args={location}},{text=fishapedia,callback=load_area,args={-2}},{text=save menu,callback=swap_menu_context,args={saving menu}}}},{name=location,prev=main,position={5,70},content={{text=beach,callback=load_area,args={1}},{text=river,callback=load_area,args={2}},{text=lake,callback=load_area,args={3}}}},{name=saving menu,prev=main,position={5,70},content={{text=save,callback=save},{text=save and quit,callback=save_and_quit},{text=quit without saving,callback=load_area_state,args={title,-3}}}},{name=switch_rods,prev=fishing,position={5,70},content=switch_rods_menu,hint=display_rod_selection_icon},{name=shop,position={5,70},content={{text=sell all fish,callback=sell_all_fish},{text=buy rods,callback=enable_rod_shop}}},{name=fishing,position={5,70},content={{text=return to map,callback=load_area_state,args={main,-1}},{text=switch rods,callback=swap_menu_context,args={switch_rods}}}}},text={60,5,7,1},gauge_data={position={10,10},size={102,5},settings={4,7,2,3},req_tension_ticks=20,tension_timer=30},power_gauge_colors={8,9,10,11,3},biases={weight=8,size=3},sell_weights={per_weight_unit=3,per_size_unit=2},shopkeeper={sprite=238},animation_data={cat={data={{sprite=232},{sprite=234}},size=16,ticks_per_frame=5},menu_selector={data={{sprite=32,offset={0,0}},{sprite=32,offset={-1,0}},{sprite=32,offset={-2,0}},{sprite=32,offset={-3,0}},{sprite=32,offset={-2,0}},{sprite=32,offset={-1,0}}},ticks_per_frame=3},up_arrow={data={{sprite=33,offset={0,0}},{sprite=33,offset={0,-1}},{sprite=33,offset={0,-2}},{sprite=33,offset={0,-1}}},ticks_per_frame=3},down_arrow={data={{sprite=49,offset={0,0}},{sprite=49,offset={0,1}},{sprite=49,offset={0,2}},{sprite=49,offset={0,1}}},ticks_per_frame=3}},rods={{name=sticky the rod,power=0,description=a stick with a string on it. the most basic of basic fishing rods.,cost=10,spriteID=200},{name=good rod,power=3,description=a pretty good rod per the name. you've seen some kids with pocket-sized monsters use this thing before.,cost=50,spriteID=202},{name=fisherman classic,power=7,description=a classic rod chosen by professionals of the industry and your uncle joey.,cost=100,spriteID=204},{name=peerless pole,power=10,description=a legendary rod passed down by the most skilled of fishing artisans and fearless warriors.,cost=500,spriteID=206}},areas={{name=beach,position={60,55},music={},fishes={{gradient={8,9,10,11,11,11,10,9,8},successIDs={11},min_gauge_requirement=1,max_gauge_requirement=3,stats={goldfish,2,2.7,12.5,1},units={cm,g},description=made with real cheese. not actual cheese; it's a fake cheese brand that's called real cheese. the more you know!},{gradient={8,9,10,11,10,9,8},successIDs={11},min_gauge_requirement=6,max_gauge_requirement=inf,stats={yellowfin tuna,4,32,2.25,4},units={m,kg},description=named such because it's got yellow fins. people like to eat it but not as much as albacore for-tuna-tely.},{gradient={8,9,10,10,10,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=3,max_gauge_requirement=6,stats={pufferfish,6,0.08,60,3},units={cm,kg},description=in a pinch it'll inflate and get prickly; makes it great for particularly vindictive matches of any inflatable variety of sportsball.},{gradient={8,9,10,11,11,11,11,11,10,9,8},successIDs={11},min_gauge_requirement=2,max_gauge_requirement=4,stats={triggerfish,8,0.04,71,2},units={cm,kg},description=it's got a gun watch out! fortunately fish do not have thumbs and thus are forced to always practice trigger discipline. don't drop this guy though.},{gradient={8,9,10,11,11,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=2,max_gauge_requirement=4,stats={ocean sunfish,66,2.2,1,2},units={m,kg},description=named after the sun which is a deadly laser. large and in charge just like the actual sun of our solar system.},{gradient={8,9,10,11,11,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=4,max_gauge_requirement=8,stats={clownfish,72,0.007,15,3},units={cm,kg},description=the practical aquatic jokester. two whole animated feature films got made about this guy! maybe not this guy in particular.},{gradient={8,9,10,11,11,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=2,max_gauge_requirement=4,stats={bonefish,74,2.7,12.5,1},units={cm,g},description=it's got a bone to pick with you. you've also got a bone to pick with it for getting hooked on your line.},{gradient={8,9,10,11,11,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=2,max_gauge_requirement=4,stats={angelfish,96,0.015,25,2},units={cm,kg},description=not biblically accurate because it's just a normal fish. makes a mean angel food cake though.},{gradient={8,9,10,11,11,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=3,max_gauge_requirement=6,stats={angle fish,98,0.015,25,3},units={cm,kg},description=a particularly obtuse-looking fish. ask them about trigonometry and the unit circle; they got pretty good grades in high school pre-calc.},{gradient={8,9,10,11,11,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=5,max_gauge_requirement=8,stats={archangelfish,100,0.015,25,4},units={cm,kg},description=pretty biblically accurate for a fish. be not afraid my child. will or will not pass judgment on how well you fish.},{gradient={8,9,11,11,11,11,11,11,11,9,8},successIDs={11},min_gauge_requirement=1,max_gauge_requirement=5,stats={plastic fish,104,2.7,12.5,1},units={cm,g},description=an assembled pvc scale model of a fish. the dominant contributor of microplastics in this body of water. maybe don't eat any of your catches.},{gradient={8,9,11,11,11,11,11,11,11,9,8},successIDs={11},min_gauge_requirement=13,max_gauge_requirement=15,stats={cat...fish,234,0.07,25,5},units={cm,g},disabled=true,description=not to be confused with an actual catfish; it's one of your own kind. what's this guy even doing? deep sea bare hands fishing? maybe that'll be you some other time.},{gradient={8,9,11,11,11,11,11,11,11,9,8},successIDs={11},min_gauge_requirement=1,max_gauge_requirement=3,stats={anchovy,108,1.02,20,1},units={cm,g},description=usually comes in tins but this one's hot-n-ready. reeled in 30 minutes or less or else your catch is free.},{gradient={8,9,11,11,11,11,11,11,11,9,8},successIDs={11},min_gauge_requirement=6,max_gauge_requirement=8,stats={squid,110,2.76,30,3},units={cm,g},description=can also turn into a kid in a not-so-distant future. either that or they become a very grumpy neighbor.},{gradient={8,9,11,11,11,11,11,11,11,9,8},successIDs={11},min_gauge_requirement=1,max_gauge_requirement=inf,stats={trashcan,230,0.02,68,1},units={cm,g},disabled=true,description=i've heard one cat's trash is another cat's treasure but this is ridiculous. at least it's not in the water anymore! do your part for the environment kids.}}},{name=river,position={46,60},music={},fishes={{gradient={8,9,10,11,11,11,10,9,8},successIDs={11},min_gauge_requirement=1,max_gauge_requirement=3,stats={carp,10,0.12,122,1},units={cm,kg},description=oh carp? one of the pillars of fishing. major contributor to cuisine and societies at large. that and it's skilled at carpentry.},{gradient={8,9,10,11,11,11,10,9,8},successIDs={11},min_gauge_requirement=2,max_gauge_requirement=4,stats={salmon,12,14.6,1.5,2},units={m,kg},description=not to be confused with salmonella; this guy won't kill you if you eat it cooked or raw! particularly violent around squids for some reason.},{gradient={8,9,10,11,11,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=11,max_gauge_requirement=13,stats={rainbow trout,38,0.013,110,5},units={cm,kg},description=typically bright and reflective colors like this are meant to ward off predators but since you're a cat the shiny lights are purr-dy.},{gradient={8,9,10,11,11,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=2,max_gauge_requirement=4,stats={smallmouth bass,40,0.02,45,2},units={cm,kg},description=always left in the shadow of the superior largemouth bass. this one's part of a small rock outfit! they do not play the bass contrary to what you may think.},{gradient={8,9,10,11,11,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=2,max_gauge_requirement=4,stats={bluegill,44,0.04,25,2},units={cm,kg},description=more green than anything else. its gills aren't even blue dude. that's kinda lame.},{gradient={8,9,10,11,11,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=2,max_gauge_requirement=4,stats={yellow pike,46,0.046,80,2},units={cm,kg},description=ride this thing around your local college campus. also known as the walleye which has no relation to the movie you're thinking of.},{gradient={8,9,10,11,11,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=2,max_gauge_requirement=4,stats={alligator gar,64,9.8,1.8,2},units={m,kg},description=won't ever need dentures because this guy's got some gnarly chompers. god forbid it bites you. don't let it bite you.},{gradient={8,9,10,11,11,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=2,max_gauge_requirement=4,stats={bonefish,74,2.7,12.5,1},units={cm,g},description=it's got a bone to pick with you. you've also got a bone to pick with it for getting hooked on your line.},{gradient={8,9,10,11,11,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=5,max_gauge_requirement=8,stats={arowana,102,2.18,1.2,3},units={m,kg},description=valuable and highly coveted in some regions. its name only really makes it sound like a brand of bottled water or something.},{gradient={8,9,11,11,11,11,11,11,11,9,8},successIDs={11},min_gauge_requirement=8,max_gauge_requirement=14,stats={catfish,106,0.03,72,4},units={cm,kg},description=the owner of a particularly intricate and very funny set of facial hair. not to be confused with a fish that is actually a cat or something.},{gradient={8,9,11,11,11,11,11,11,11,9,8},successIDs={11},min_gauge_requirement=1,max_gauge_requirement=inf,stats={trashcan,230,0.02,68,1},units={cm,g},disabled=true,description=i've heard one cat's trash is another cat's treasure but this is ridiculous. at least it's not in the water anymore! do your part for the environment kids.}}},{name=lake,position={54,64},music={},fishes={{gradient={8,9,10,11,11,11,10,9,8},successIDs={11},min_gauge_requirement=1,max_gauge_requirement=3,stats={carp,10,0.12,122,1},units={cm,kg},description=oh carp? one of the pillars of fishing. major contributor to cuisine and societies at large. that and it's skilled at carpentry.},{gradient={8,9,10,11,11,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=2,max_gauge_requirement=4,stats={largemouth bass,14,0.01,45,2},units={cm,kg},description=talks a big game but is actually quite timid. it and most of its genetic relatives are hated by most anthropomorphic animal island dwellers.},{gradient={8,9,10,11,11,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=11,max_gauge_requirement=13,stats={rainbow trout,38,0.013,110,5},units={cm,kg},description=typically bright and reflective colors like this are meant to ward off predators but since you're a cat the shiny lights are purr-dy.},{gradient={8,9,10,11,11,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=2,max_gauge_requirement=4,stats={crappie,42,0.02,38,2},units={cm,kg},description=also known as the calico bass so whoever gave it this particular name was probably having a really bad day.},{gradient={8,9,10,11,11,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=2,max_gauge_requirement=4,stats={sturgeon,68,30.7,4.8,2},units={m,kg},description=went to medical school and was making six figures as part of an experienced surgical team. until you showed up that is.},{gradient={8,9,10,11,11,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=4,max_gauge_requirement=10,stats={koi,70,0.076,60,4},units={cm,kg},description=this guy'll apparently turn into a dragon if it does a sick enough jump up a river per japanese legend. unfortunately that won't happen now.},{gradient={8,9,10,11,11,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=2,max_gauge_requirement=4,stats={bonefish,74,2.7,12.5,1},units={cm,g},description=it's got a bone to pick with you. you've also got a bone to pick with it for getting hooked on your line.},{gradient={8,9,10,11,11,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=2,max_gauge_requirement=4,stats={killifish,76,3,7.6,2},units={cm,g},description=killer fish. killer fish from san diego. doesn't know what they are but they taste really good.},{gradient={8,9,10,11,11,10,11,11,10,9,8},successIDs={11},min_gauge_requirement=1,max_gauge_requirement=3,stats={pond smelt,78,1.9,11,2},units={cm,g},description=they who smelt it dealt it. or in this case caught it. because you caught it. pee-ew.},{gradient={8,9,11,11,11,11,11,11,11,9,8},successIDs={11},min_gauge_requirement=8,max_gauge_requirement=14,stats={catfish,106,0.03,72,4},units={cm,kg},description=the owner of a particularly intricate and very funny set of facial hair. not to be confused with a fish that is actually a cat or something.},{gradient={8,9,11,11,11,11,11,11,11,9,8},successIDs={11},min_gauge_requirement=1,max_gauge_requirement=inf,stats={trashcan,230,0.02,68,1},units={cm,g},disabled=true,description=i've heard one cat's trash is another cat's treasure but this is ridiculous. at least it's not in the water anymore! do your part for the environment kids.}}}}"
function reset()
  global_data_table = unpack_table(global_data_str)
  shop_sprite_sheet = "641264126412641264126412641264126412644744126412641264123417241225441264126412147264826412641264122415341264126412541714122417341264121415441264123417241215174412641264127412341524126412641264126412641264126412441724123417241264126412641234172412151744126412641234153412641224153412641264126412641264126412341734124417141264826412341724121517441264126412748264126412641264826412641224c5126412641264124417141215174412641264127412641264126412641264126412641264122415a1151214154412441514126452172215174412641264127412441514126412641224153412641264126412141524151412241521191139311512441514126412641244171412151744123415241264127412641264126412641264123415241264126412241521692115126412641264121415241714121517441264126412741264126412648264126412648224152119113931158264126412441714121517448264127412641264126412641264126412641264122415a1151264126412641244161412151715341264126412741264126412641264126412641264123415241224c51234152412641264122416141614122544122415341264127412343f122f141f243f143f1264122415341264126412641274126412641264126412341624121517441264126412741224ff4f4415141264126412441514126412741264126412641224153412641215174412641264127412144f201f101f102f102f202f126482641264126412741264126412641264126412151744126412441514127412341f103f101f101f101f101f101f102f6412641264126412641234153412641264126482641215174412641264127412243f102f301f101f101f202f12641264126482641274126412641214164412641264121517441264827412142f203f101f102f102f104f6412441514126412641264121472641264123634124415141264121517441264126412741224ff3f126412641264121415241514126412741264126412141620241264126412151744126412241534122415441224ff1f141f1264126412641264126412741264126412342014181418441264121517153412641264127412341f24121f141f34122f141f241264126412641254206412541514126412641244201814184412641225441264126412147264126482641264176412143120122415341274124415141264124416201654126412151744126412641274126412641264126412541712173436312021141514152412741264126412341615161016154412641215174412641264127412641264124415141264125417122524466185648264123416554412641215175264126412741264126412641264124417141215174412dd127412641264124455441264121517441264126412541514126412341524126412641244171412151744126412641214fdad557d18cd509d641264121415441264126412441714121517441264126412149d57bd557d17bd704d183d64126412641264126412441714121517441264126412148d175d17ad55dd572d504d382d6412648264126412441714121517441264126412145d26177d173d186d35bd375d774d382d6412641264126412641234172412151724151412641214154412144d169d173d38dd164d179d1057103d372d6412141524151412641264126412341724121517441264126412145d164d18172d173d37cd163d27bd504d372d6412641264126412641234172412151752648214fd173d17ed2617fd8d173d648264126412641234172412151744126412641214fd1d17fdfdfd2df0f0f0f0f0f0f0f0"
  map_table = {
    "fcfcfcfcfc8c139c33ac33fc1c33fcfcfcfcfc7c337c538c536c137c43fcfc3c102c102c10fcfccc336c737c635c136c53fcfc4c201c20fcfccc534c935c635c335c538c6afcfc7c102c102c106cf121535f732f142f834f333f736caabc101c101c10fc5c201c207cf14f146f935f832f531f835ccabc101c10fcfc3ce12f148fb32fb31f533f634ceafc4c101c101c10fc7cd1ef736f834f144f733cfa1afc4c101c10fc8c4114817f234f932f141f938f833cfa1afcfcfc2124917f23192fb31fc35fa32cfa3afcfcec1124a11c3f26209f147fa32fe32cfa3afc7c102c102c10fce12c46105f143f146fc34fb32cfa3afc8c201c20fc1cf12c469f145fe37f732cfa3afcfcecf1112c191cff7f246f144f932cfa3afcfcecc11c512cff3f202f247fd32cfa3afcfcecd11c412c5f25af50245ff33cfa1adc101c101c10fcccd11c412cff142f50df833cfa1aec101c10fcdcc11c512caf148f50bf934ceafcfcfc1cb11c513c1f84af151015afc35ccafcfc5c101c101c107cf1113c2489247f553ff3336caafcfc7c101c108c611c714c14c9144f757fe38c6afcfcfc5c711c416c14c9142fa53f146fa3fcfcfcfc4c711c316c1f3489342fa58fc3fcfcfcfc4c611c414c3fe43f857fe3fcfcfcfc4c611c313c5fe4ff2ff38c102c102c10fcfcfc4c511c412c1f143ff414dff3339c201c20fcfcfc5c913c4ff4349ff363fcfcfcfc3c13813c3ff4745f14ff74fcfc1c13fcfc1c13812c2f641f541fc4ff5f74fcfc1c13bc13fc4c13713c445f345f445f24af148f74fcfc33ac13fc3c23712caf347f34ff7f142f74fcfc339c33fc1c33711caf343f145f342f14ff6f74f0f0f0f0f0f0f0f0",
    "f18117f1d1178117f1f1f1f1b1179117f11117a117c11b611bf1f1e13c311cf1311b5117711b7117111b611bc11b611b11171113211bf1f1b13c313cf117213bc11b912b2113211b21171b6117111b2113213b2113112bf1313c313cf1f1a1133b611b2113113b13111b1113213b2113113b13111b3113312b2113114b11332bf1112c313c311cf1f191232b1123311b1123112b232b23114b11234b232b1123213b11334b333bf1f1f1f161333b23212b11233b232b23115b332b233b435b432b334bf1f1f1f141171b332b433b11233b134b234b432b234b334b532b235bf1f1f1f1511b431b131b233b332b234b234b736b332b936bf1f1f1f1412b632b231b735b332b738bf34bf1f1f1f1411b732b231b637b233b736be36bf1f1f1f141734b837b232b738bc37bf1f1f1f141635b838ba39ba38bf1f1f1f141536b63ab93bbb36bf1f1f1f141537b63ab63bbb38bf1f1f1f141637b638b93ab939bf1f1f1f14143ab33cb63cb73abf1f1f1f14123cb23eb33fb1b639b211c312c311cf1f1f171439b43fb142f243f244f83ab313c213cf1f1f18133bb13fb2b147f246f241f24bbf1f1f1f141fb8b246f244f14df248f34f1f1f1f1411ffb4f241f242f1bff1f1bbf1b4f34f1f1f1f1411f14ab2f242f1b4f241f1b4f142f1baf1b143f1b5f1b3f143ff131f292911c811c311f243f246f242f2b9f1b8f258f3b6f143f1b2ff131221410f45412912c412c111c216f243f141f1b1f1bbf1b1f241f143f1b4f147f1b2f149f1b1ff131121412f4641012a14c412c4f253f1b2f4b3f147f1b1f443f1b6f2b4f1b8f2b4ff1311214f2a2f1411f141f1b3f1b1f2b2f2b3f144f255f347f1b1f2b9f1b2f141f1b5ff13112141211121410f45412f1312f1b5f4b1f1b7f141f256f343f143f2b9f3b6f142ff1311214122112f454101412f1214f141baf142b8f5c349f147f2b3f156ff13112141221f2a2f111145f1b2f147f1b5f5c411c24df7c9ff1211c1214121c11121412f4641012f15fcc1f5ca1ac2f4c618c1ff1313c211214221410f45412e12f3cb13cf1813cf1311cf18112141211f292d1f0f0f0f0f0f0f0f0"
  }
  fish_inventory = {}
  current_rod = global_data_table.rods[1]
  rod_inventory = {current_rod}
  compendium_rect = BorderRect:new(
    Vec:new(8, 8), Vec:new(111, 111),
    7, 5, 3
  )
  compendium_sprite_rect = BorderRect:new(
    compendium_rect.position + Vec:new(5, 5),
    Vec:new(24, 24), 
    7, 0, 2
  )
  opened_fish_page = nil
  menus = {}
  for data in all(global_data_table.menu_data) do 
    add(menus, Menu:new(
      data.name,
      data.prev,
      Vec:new(data.position),
      parse_menu_content(data.content),
      _ENV[data.hint],
      unpack(global_data_table.palettes.menu)
    ))
  end
  fishing_areas = {}
  for area in all(global_data_table.areas) do
    add(fishing_areas, FishingArea:new(area))
  end
  
  show_fish_details, fish_detail_flag = false
  show_rod_shop, show_rod_details, rod_detail_flag = false
  fishpedia = Inventory:new(34, 36, 
    Vec:new(5, 5), 30, 
    { Vec:new(8, 8), Vec:new(111, 111), 7, 5, 3 }
  )
  local fish_names, count = {}, 0
  for area in all(global_data_table.areas) do 
    for fish in all(area.fishes) do 
      if not table_contains(fish_names, fish.stats[1]) then 
        Inventory.add_entry(
          fishpedia, 
          count, 
          fish.stats[2], 
          fish.stats[1], 
          {
            description = fish.description,
            units = fish.units,
            rarity = fish.stats[5]
          }, 
          true,
          fish.disabled and false or true
        )
        add(fish_names, fish.stats[1])
        count += 1
      end
    end
  end
  cat = Animator:new(global_data_table.animation_data.cat, true)
  shopkeeper = global_data_table.shopkeeper
  rod_shop = Inventory:new(34, 36,
      Vec:new(2, 2), 4, 
      { Vec:new(75, 11), Vec:new(45, 45), 5, 4, 3}, Vec:new(60,-4)
  )
  for i, rod in pairs(global_data_table.rods) do
    Inventory.add_entry(rod_shop, i-1, rod.spriteID, rod.cost, {}, false)
  end
  Inventory.get_entry(rod_shop, 0).is_disabled = true
  credit_y_offsets = {}
  for y in all(global_data_table.credit_offsets) do 
    add(credit_y_offsets, y)
  end
  boid_array = {}
  for i=1, 15 do 
    add(boid_array, Boid:new(Inventory.get_random_sprite(fishpedia), rnd(127), rnd(127)))
  end
  cash = 100
  loaded_area = -3
  get_menu("title").enable = true
end
BorderRect = {}
function BorderRect:new(position_, size_, border_color, base_color, thickness_size)
  obj = {
    position = position_, 
    size = position_ + size_,
    border = border_color, 
    base = base_color,
    thickness = thickness_size
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end
function BorderRect:draw()
  rectfill(
    self.position.x-self.thickness, self.position.y-self.thickness, 
    self.size.x+self.thickness, self.size.y+self.thickness, 
    self.border
  )
  rectfill(self.position.x, self.position.y, self.size.x, self.size.y, self.base)
end
function BorderRect:resize(position_, size_)
  if (self.position ~= position_) self.position = position_
  if (self.size ~= size_ + position_) self.size = size_ + position_ 
end
function BorderRect:reposition(position_)
  if (self.position == position_) return
  local size = self.size - self.position
  self.position = position_
  self.size = self.position + size
end
GradientSlider = {}
function GradientSlider:new(
  position_, size_, gradient_colors, handle_color, outline_color, thickness_, speed_)
  obj = {
    position=position_, 
    size=size_, 
    colors=gradient_colors,
    handle=handle_color,
    outline=outline_color,
    thickness=thickness_,
    speed=speed_,
    handle_size=Vec:new(3, size_.y+4),
    pos=0,
    dir=1
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end
function GradientSlider:draw()
  local rect_size = self.position + self.size
  rectfill(
    self.position.x-self.thickness, self.position.y-self.thickness, 
    rect_size.x+self.thickness, rect_size.y+self.thickness, 
    self.outline
  )
  for y=0, self.size.y do
    for x=0, self.size.x do
      local pixel_coord = Vec:new(x, y) + self.position 
      pset(pixel_coord.x, pixel_coord.y, self.colors[GradientSlider.get_stage(self, x)])
    end
  end
  local handle_pos = self.position + Vec:new(self.pos, -2)
  local handle_size = handle_pos + self.handle_size
  rectfill(
    handle_pos.x-self.thickness, handle_pos.y-self.thickness,
    handle_size.x+self.thickness, handle_size.y+self.thickness,
    self.outline
  )
  rectfill(
    handle_pos.x, handle_pos.y,
    handle_size.x, handle_size.y,
    self.handle
  )
end
function GradientSlider:update()
  self.pos = mid(self.pos + self.speed, 0, self.size.x)
end
function GradientSlider:reduce()
  self.pos = mid(self.pos - self.speed, 0, self.size.x)
end
function GradientSlider:get_stage(x)
  local p = x or self.pos
  local rate = flr((p / self.size.x) * 100)
  local range = self.size.x \ #self.colors
  return mid(rate \ range + 1, 1, #self.colors)
end
function GradientSlider:reset()
  self.pos = 0
  self.dir = 1
end
Fish = {}
function Fish:new(fish_name, description_, spriteID, weight, fish_size, fish_rarity, units_, gradient, successIDs)
  local star_string = fish_rarity .. "★"
  local string_len = longest_string({
    "name: "..fish_name.." "..star_string,
    "weight: "..weight..units_[2],
    "size: "..fish_size..units_[1],
    "press ❎ to close"
  })*5-5
  local box_size = Vec:new(string_len, 40)
  local gauge_data = global_data_table.gauge_data
  obj = {
    name=fish_name,
    sprite = spriteID,
    lb = weight,
    size = fish_size,
    rarity = fish_rarity,
    units = units_,
    description=description_,
    success_stage_ids = successIDs,
    tension_slider = GradientSlider:new(
      Vec:new(gauge_data.position), Vec:new(gauge_data.size), 
      gradient, unpack(gauge_data.settings)
    ),
    description_box = BorderRect:new(
      Vec:new((128-box_size.x-6) \ 2, 80), box_size, 
      7, 1, 3
    ),
    ticks = 0,
    timer = global_data_table.gauge_data.tension_timer
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end
function Fish:update()
  if (self.ticks >= global_data_table.gauge_data.req_tension_ticks) return
  if Fish.catch(self) then
    self.ticks += 1
    self.timer = min(self.timer+1, global_data_table.gauge_data.tension_timer)
  else
    self.timer = max(self.timer-1, 0)
  end
  GradientSlider.update(self.tension_slider)
end
function Fish:draw_tension()
  local thickness = self.tension_slider.thickness
  local pos = self.tension_slider.position-Vec:new(thickness, 0)
  local size = self.tension_slider.size
  local y = pos.y+size.y+thickness+1
  line(pos.x, y, pos.x + (self.ticks/global_data_table.gauge_data.req_tension_ticks)*size.x+thickness, y, 11)
  line(pos.x, y+1, pos.x + (self.timer/global_data_table.gauge_data.tension_timer)*size.x+thickness, y+1, 8)
  GradientSlider.draw(self.tension_slider)
end
function Fish:draw_details()
  line(62, 0, 62, 48, 7)
  draw_sprite_rotated(self.sprite, Vec:new(55, 48), 16, 90)
  BorderRect.draw(self.description_box)
  local star_string = self.rarity .. "★"
  print_with_outline(
    "name: "..self.name.." "..star_string.."\n\nrweight: "..self.lb..self.units[2].."\nsize: "..self.size..self.units[1].."\n\npress ❎ to close", 
    self.description_box.position.x + 5, self.description_box.position.y + 4, 7, 0
  )
end
function Fish:catch()
  return table_contains(
    self.success_stage_ids, 
    self.tension_slider.colors[GradientSlider.get_stage(self.tension_slider)]
  )
end
FishingArea = {}
function FishingArea:new(area_data_)
  local lost_text_len = #"the fish got away"*5-5
  obj = {
    area_data = area_data_,
    power_gauge = GradientSlider:new(
      Vec:new(global_data_table.gauge_data.position), 
      Vec:new(global_data_table.gauge_data.size), 
      global_data_table.power_gauge_colors,
      unpack(global_data_table.gauge_data.settings)
    ),
    lost_box = BorderRect:new(
      Vec:new((128-lost_text_len-6)\2, 48),
      Vec:new(lost_text_len, 24),
      7, 1, 3
    ),
    state = "none",
    fish = nil
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end
function FishingArea:draw()
  if self.state == "casting" then 
    GradientSlider.draw(self.power_gauge)
  elseif self.state == "fishing" then 
    Fish.draw_tension(self.fish)
  elseif self.state == "detail" then 
    Fish.draw_details(self.fish)
  elseif self.state == "lost" then 
    FishingArea.draw_lost(self)
  end
end
function FishingArea:draw_lost()
  BorderRect.draw(self.lost_box)
  print_with_outline(
    "the fish got away\n\npress ❎ to close", 
    self.lost_box.position.x + 5, self.lost_box.position.y+6, 7, 0
  )
end
function FishingArea:update()
  if not self.flag then 
    self.flag = true
    self.started = false
    return 
  end
  if btnp(❎) and self.state ~= "casting" then
    if self.state == "none" then 
      self.started = true
      self.state = "casting"
      sfx(49)
    elseif self.state == "lost" then 
      FishingArea.reset(self)
    elseif self.state == "detail" then 
      add(fish_inventory, {self.fish.lb, self.fish.size, self.fish.rarity})
      local entry = Inventory.get_entry(fishpedia, self.fish.name)
      entry.data = {
        description=self.fish.description,
        weight=max(entry.data.weight, self.fish.lb),
        size=max(entry.data.size, self.fish.size),
        units=self.fish.units,
        rarity = max(entry.data.rarity, self.fish.rarity)
      }
      entry.is_hidden = false
      FishingArea.reset(self)
    end
  end
  if btn(❎) then 
    if self.state == "casting" and self.started then
      GradientSlider.update(self.power_gauge)
    elseif self.state == "fishing" then 
      sfx(62)
      self.started = true
      Fish.update(self.fish)
      if self.fish.timer <= 0 then 
        self.state = "lost"
      end
    end
  else
    if self.state == "fishing" and self.started then
      GradientSlider.reduce(self.fish.tension_slider)
    elseif self.state == "casting" then 
      sfx(61)
      self.state = "fishing"
      self.started = false
      self.fish = generate_fish(
        self.area_data, 
        GradientSlider.get_stage(self.power_gauge)
      )
      if (self.fish == nil) self.state = "lost" 
      if self.fish then 
        if self.fish.rarity <= 2 then 
          music(0)
        elseif self.fish.rarity == 3 then 
          music(8)
        elseif self.fish.rarity > 3 then 
          music(19)
        end
      end
      GradientSlider.reset(self.power_gauge)
    end
  end
  if self.state == "fishing" and self.fish.ticks >= global_data_table.gauge_data.req_tension_ticks then  
    if self.fish then 
      if self.fish.rarity <= 2 then 
        sfx(33)
      elseif self.fish.rarity == 3 then 
        sfx(29)
      elseif self.fish.rarity > 3 then 
        sfx(27)
      end
    end
    self.state = "detail" 
    GradientSlider.reset(self.fish.tension_slider)
  end
end
function FishingArea:reset()
  self.started = false
  self.fish = nil 
  self.state = "none"
  self.flag = false
  music(-1)
  sfx(-1)
end
function generate_fish(area, stage)
  local possible_fishes = {}
  local stage_gauge = stage + current_rod.power
  for fish in all(area.fishes) do
    if stage_gauge >= fish.min_gauge_requirement and stage_gauge < fish.max_gauge_requirement then 
      add(possible_fishes, fish)
    end
  end
  if (#possible_fishes == 0) return nil
  local fish = possible_fishes[flr(rnd(#possible_fishes))+1]
  local name, spriteID, weight, size, rarity = unpack(fish.stats)
  size, weight = generate_weight_size_with_bias(weight, size)
  return Fish:new(
    name, fish.description, spriteID, weight, size, rarity, fish.units, fish.gradient, fish.successIDs
  )
end
function generate_weight_size_with_bias(weight, size)
  local bias = global_data_table.biases.size
  local new_size = round_to(mid(size + rnd(bias) - bias/2, 0.1, size + bias), 2)
  local new_weight = round_to(weight * new_size * 0.3 * global_data_table.biases.weight, 2)
  return new_size, new_weight
end
Vec = {}
function Vec:new(dx, dy)
  local obj = nil
  if type(dx) == "table" then 
    obj = {x=dx[1],y=dx[2]}
  else
    obj={x=dx,y=dy}
  end
  setmetatable(obj, self)
  self.__index = self
  self.__add = function(a, b)
    return Vec:new(a.x+b.x,a.y+b.y)
  end
  self.__sub = function(a, b)
    return Vec:new(a.x-b.x,a.y-b.y)
  end
  self.__mul = function(a, scalar)
    return Vec:new(a.x*scalar,a.y*scalar)
  end
  self.__div = function(a, scalar)
    return Vec:new(a.x/scalar,a.y/scalar)
  end
  self.__eq = function(a, b)
    return (a.x==b.x and a.y==b.y)
  end
  self.__tostring = function(vec)
    return "("..vec.x..", "..vec.y..")"
  end
  self.__concat = function(vec, other)
    return (type(vec) == "table") and Vec.__tostring(vec)..other or vec..Vec.__tostring(other)
  end
  return obj
end
function Vec:unpack()
  return self.x, self.y
end
function Vec:clamp(min, max)
  self.x, self.y = mid(self.x, min, max), mid(self.y, min, max)
end
function Vec:magnitude()
  return sqrt(self.x^2 + self.y^2)
end
function Vec:normalize()
  local length = Vec.magnitude(self)
  return Vec:new(self.x / length, self.y / length)
end
function Vec:heading()
  local theta = self.y/self.x
  return sin(theta)/cos(theta)
end
function Vec:limit(value)
  return Vec:new(min(self.x, value), min(self.y, value))
end
function distance(a, b)
  return sqrt((a.x-b.x)^2 + (a.y-b.y)^2)
end
function normalize(val)
  return (type(val) == "table") and Vec:new(normalize(val.x), normalize(val.y)) or flr(mid(val, -1, 1))
end
function lerp(start, last, rate)
  return start + (last - start) * rate
end
Menu = {}
function Menu:new(
  menu_name, previous_menu, position_, 
  menu_content, menu_info_draw_call, 
  base_color, border_color, text_color, menu_thickness)
  obj = {
    name = menu_name,
    prev = previous_menu,
    position = position_,
    selector = Animator:new(global_data_table.animation_data.menu_selector, true),
    up_arrow = Animator:new(global_data_table.animation_data.up_arrow, true),
    down_arrow = Animator:new(global_data_table.animation_data.down_arrow, true),
    content = menu_content,
    content_draw = menu_info_draw_call,
    rect = BorderRect:new(
      position_, 
      Vec:new(min(10 + 5*longest_menu_str(menu_content), 128-position_.x-menu_thickness*2), 38),
      border_color,
      base_color,
      menu_thickness
    ),
    text = text_color,
    pos = 1,
    enable = false,
    ticks = 5,
    max_ticks = 5,
    dir = 0
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end
function Menu:draw()
  if (not self.enable) return
  local top, bottom = self.pos-1, self.pos+1
  if (top < 1) top = #self.content 
  if (bottom > #self.content) bottom = 1
  if (self.content_draw) self.content_draw(self.pos, self.position, self.content[self.pos].color)
  BorderRect.draw(self.rect)
  Animator.draw(self.selector, Vec.unpack(self.position + Vec:new(2, 15)))
  local arrow_offset = (self.rect.size.x + self.rect.position.x)\2-self.up_arrow.sprite_size\2
  Animator.draw(self.up_arrow, arrow_offset, self.position.y-self.rect.thickness)
  Animator.draw(self.down_arrow, arrow_offset, self.rect.size.y-self.rect.thickness)
  local base_pos_x = self.position.x+10
  local menu_scroll_data = {self.dir, self.ticks / self.max_ticks, self.position}
  if self.ticks < self.max_ticks then 
    if self.dir > 0 then 
      print_with_outline(
        self.content[top].text, 
        combine_and_unpack(menu_scroll(12, 10, 7, unpack(menu_scroll_data)), 
        self.content[top].color)
      )
    elseif self.dir < 0 then 
      print_with_outline(
        self.content[bottom].text, 
        combine_and_unpack(menu_scroll(12, 10, 27, unpack(menu_scroll_data)), 
        self.content[bottom].color)
      )
    end 
  else
    print_with_outline(self.content[top].text, base_pos_x, self.position.y+7, unpack(self.content[top].color))
    print_with_outline(self.content[bottom].text, base_pos_x, self.position.y+27, unpack(self.content[bottom].color))
  end
  print_with_outline(
    self.content[self.pos].text, 
    combine_and_unpack(menu_scroll(10, 12, 17, unpack(menu_scroll_data)), 
    self.content[self.pos].color)
  )
end
function Menu:update()
  if (not self.enable) return
  Animator.update(self.selector)
  Animator.update(self.up_arrow)
  Animator.update(self.down_arrow)
  if (self.ticks >= self.max_ticks) return
  self.ticks += 1
end
function Menu:move()
  if (not self.enable) return
  if (self.ticks < self.max_ticks) return
  local _, dy = controls()
  if (dy == 0) return
  sfx(58)
  self.pos += dy 
  self.dir = dy
  if (self.pos < 1) self.pos = #self.content 
  if (self.pos > #self.content) self.pos = 1
  self.ticks = 0
end
function Menu:invoke()
  if (self == nil) return
  local cont = self.content[self.pos]
  if (cont.callback == nil) return
  if cont.args then
    cont.callback(unpack(cont.args))
  else
    cont.callback()
  end
  sfx(59)
end
function Menu:update_content(content)
  self.content = content 
  BorderRect.resize(
    self.rect,
    self.rect.position, 
    Vec:new(5*longest_menu_str(content), 38)
  )
end
function menu_scroll(dx1, dx2, dy, dir, rate, position)
  local dy1, dy3 = dy-10, dy+10
  local lx = lerp(position.x+dx1, position.x+dx2, rate)
  local ly = position.y + dy
  if dir < 0 then 
    ly = lerp(position.y + dy1, ly, rate)
  elseif dir > 0 then 
    ly = lerp(position.y + dy3, ly, rate)
  end
  return {lx, ly}
end
Animator = {} -- updated from tower_defence
function Animator:new(animation_data, continuous_)
  obj = {
    data = animation_data.data,
    sprite_size = animation_data.size or 8,
    spin_enable = animation_data.rotation,
    theta = 0,
    animation_frame = 1,
    frame_duration = animation_data.ticks_per_frame,
    tick = 0,
    continuous = continuous_
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end
function Animator:update()
  self.tick = (self.tick + 1) % self.frame_duration
  self.theta = (self.theta + 5) % 360
  if (self.tick ~= 0) return false
  if Animator.finished(self) then 
    if (self.continuous) Animator.reset(self)
    return true
  end
  self.animation_frame += 1
  return false
end
function Animator:finished()
  return self.animation_frame >= #self.data
end
function Animator:draw(dx, dy)
  local position,frame = Vec:new(dx, dy),self.data[self.animation_frame]
  if (frame.offset) position += Vec:new(frame.offset)
  if self.spin_enable then 
    draw_sprite_rotated(frame.sprite, position, self.sprite_size, self.theta)
  else
    spr(Animator.get_sprite(self),combine_and_unpack({Vec.unpack(position)}, {self.sprite_size\8, self.sprite_size\8}))
  end
end
function Animator:get_sprite()
  return self.data[self.animation_frame].sprite
end
function Animator:reset()
  self.animation_frame = 1
end
Inventory = {}
function Inventory:new(selector_spr_id, unknown_spr_id, size_, max_entries, border_rect_data, offset_)
  obj = {
    selector_id = selector_spr_id,
    unknown_id = unknown_spr_id,
    size = size_,
    entry_amount = max_entries,
    rect = BorderRect:new(unpack(border_rect_data)),
    data = {},
    spacing = 4,
    pos = 0,
    min_pos = 0,
    max_pos = size_.x*size_.y,
    grid_size = size_.x*size_.y,
    offset = offset_ or Vec:new(-4,-4),
    disabled_icon = 198
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end
function Inventory:draw(asdf)
  BorderRect.draw(self.rect)
  for y=1, self.size.y do
    for x=1, self.size.x do
      local position = Vec:new(x*16+self.spacing*x, y*16+self.spacing*y) + self.offset
      local index = self.min_pos + (x-1) + (y-1)*self.size.x
      local entry = self.data[index]
      if entry == nil or entry.is_hidden then 
        entry = self.unknown_id
      else
        entry = entry.sprite_id
      end
      rectfill(position.x-1, position.y-1, position.x + 16, position.y + 16, 0)
      spr(entry, position.x, position.y, 2, 2)
      if self.data[index] and self.data[index].is_disabled then 
        spr(self.disabled_icon, position.x, position.y, 2, 2)
      end
    end
  end
  local pos_offset = self.pos - self.min_pos
  local x = pos_offset%self.size.x
  local y = pos_offset\self.size.x
  local pos = Vec:new(x*16+self.spacing*x, y*16+self.spacing*y)+Vec:new(20, 20)+self.offset
  spr(self.selector_id, pos.x, pos.y, 2, 2)
end
function Inventory:update()
  local dx, dy = controls()
  self.pos += dx
  self.pos += dy*self.size.x
  if self.pos >= self.entry_amount then
    self.pos -= self.entry_amount
    self.min_pos = 0
    self.max_pos = self.grid_size
  elseif self.pos < 0 then 
    self.pos += self.entry_amount
    self.min_pos = self.entry_amount-self.grid_size
    self.max_pos = self.entry_amount
  else
    if self.pos >= self.max_pos then 
      self.min_pos += self.size.x
      self.max_pos += self.size.x
    elseif self.pos <= self.min_pos then
      self.min_pos -= self.size.x
      self.max_pos -= self.size.x
    end
    self.max_pos = mid(self.max_pos, self.grid_size, self.entry_amount)
    self.min_pos = mid(self.min_pos, 0, self.entry_amount-self.grid_size)
  end
end
function Inventory:add_entry(index, sprite, name_, extra_data, hidden, pickable)
  self.data[index] = {
    is_hidden=hidden, 
    is_disabled=false, 
    is_pickable=pickable or false,
    sprite_id = sprite, 
    name = name_, 
    data = extra_data
  }
end
function Inventory:get_entry(name)
  if type(name) == "string" then 
    for i=0, #self.data do 
      if (self.data[i].name == name) return self.data[i]
    end
  else
    return self.data[name]
  end
end
function Inventory:get_data()
  local data = {}
  for i=0, #self.data do 
    local entry = self.data[i]
    if entry and not entry.is_hidden then 
      add(data, {
        id = i,
        data = entry.data
      })
    end
  end
  return data
end
function Inventory:get_random_sprite()
  local entry = self.data[flr(rnd(#self.data))]
  while not entry.is_pickable do 
    entry = self.data[flr(rnd(#self.data))]
  end
  return entry.sprite_id
end
function Inventory:check_if_disabled()
  return self.data[self.pos].is_disabled
end
function Inventory:check_if_hidden()
  local entry = self.data[self.pos]
  return entry == nil or entry.is_hidden
end
Boid = {}
function Boid:new(sprite, x, y)
  local angle = flr(rnd()*360)
  obj = {
    sprite_id = sprite,
    position = Vec:new(x, y),
    velocity = Vec:new(cos(angle), sin(angle)),
    acceleration = Vec:new(0, 0),
    r = 2,
    max_speed = 1,
    max_force = 0.03,
    desired_sep = 15,
    neighbor_dist = 30,
    tick = 0,
    max_ticks = 10
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end
function Boid:update()
  self.velocity = Vec.limit(self.velocity + self.acceleration, self.max_speed)
  self.position += self.velocity
  self.acceleration *= 0
end
function Boid:seek(target)
  local desired = target - self.position
  local desired_norm = Vec.normalize(desired)
  desired *= self.max_speed
  return Vec.limit(desired - self.velocity, self.max_force)
end
function Boid:draw()
  local pos = lerp(self.position, self.position + Vec.limit(self.velocity + self.acceleration, self.max_speed), self.tick/self.max_ticks)
  spr(self.sprite_id, pos.x, pos.y, 2, 2)
end
function Boid:border()
  if (self.position.x < 0) self.position.x = 127
  if (self.position.y < 0) self.position.y = 127
  if (self.position.x > 127) self.position.x = 0
  if (self.position.y > 127) self.position.y = 0
end
function Boid:flock(boids)
  local sep = Boid.separate(self, boids)
  local ali = Boid.align(self, boids)
  local coh = Boid.cohesion(self, boids)
  sep *= 1.5
  self.acceleration += sep
  self.acceleration += ali
  self.acceleration += coh
end
function Boid:separate(boids)
  local steer = Vec:new(0, 0)
  local count = 0
  for other in all(boids) do 
    local dist = distance(self.position, other.position)
    if dist > 0 and dist < self.desired_sep then 
      local diff = self.position - other.position
      diff = Vec.normalize(diff)
      diff /= dist 
      steer += diff 
      count += 1 
    end
  end
  if count > 0 then 
    steer /= count 
  end
  if Vec.magnitude(steer) > 0 then 
    steer = Vec.normalize(steer)
    steer *= self.max_speed
    steer -= self.velocity
    steer = Vec.limit(steer, self.max_force)
  end
  return steer
end
function Boid:align(boids)
  local sum = Vec:new(0, 0)
  local count = 0
  for boid in all(boids) do
    local dist = distance(self.position, boid.position)
    if dist > 0 and dist < self.neighbor_dist then 
      sum += boid.velocity
      count += 1
    end
  end
  if count > 0 then 
    sum /= count 
    sum = Vec.normalize(sum)
    sum *= self.max_speed
    return Vec.limit(sum - self.velocity, self.max_force)
  else
    return Vec:new(0, 0)
  end
end
function Boid:cohesion(boids)
  local sum = Vec:new(0, 0)
  local count = 0
  for boid in all(boids) do 
    local dist = distance(self.position, boid.position)
    if dist > 0 and dist < self.neighbor_dist then 
      sum += boid.position
      count += 1
    end
  end
  if count > 0 then 
    sum /= count 
    return Boid.seek(self, sum)
  else
    return Vec:new(0, 0)
  end
end
function run(boids)
  for boid in all(boids) do 
    boid.tick = (boid.tick + 1) % boid.max_ticks
    if boid.tick == 0 then
      Boid.flock(boid, boids)
      Boid.update(boid)
      Boid.border(boid)
      Boid.draw(boid)
    end
  end
end
function _init()
  reset()
end
function _draw()
  cls()
  if loaded_area == -4 then 
    draw_credits()
  elseif loaded_area == -3 then 
    draw_title()
  elseif loaded_area == -2 then 
    draw_compendium()
  elseif loaded_area == -1 then 
    draw_map()
  elseif loaded_area == 0 then 
    draw_shop()
  elseif loaded_area > 0 then
    draw_fishing()
  end
  foreach(menus, Menu.draw)
end
function _update()
  foreach(menus, Menu.update)
  foreach(menus, Menu.move)
  if loaded_area == -4 then 
    credits_loop()
  elseif loaded_area == -3 then 
    title_loop()
  elseif loaded_area == -2 then 
    compendium_loop()
  elseif loaded_area == -1 then
    map_loop()
  elseif loaded_area == 0 then 
    get_menu("shop").enable = true
    shop_loop()
  elseif loaded_area > 0 then
    fish_loop()
  end
end
function print_with_outline(text, dx, dy, text_color, outline_color)
  ?text,dx-1,dy,outline_color
  ?text,dx+1,dy
  ?text,dx,dy-1
  ?text,dx,dy+1
  ?text,dx,dy,text_color
end
function print_text_center(text, dy, text_color, outline_color)
  print_with_outline(text, 64-(#text*5)\2, dy, text_color, outline_color)
end
function controls()
  if btnp(⬆️) then return 0, -1
  elseif btnp(⬇️) then return 0, 1
  elseif btnp(⬅️) then return -1, 0
  elseif btnp(➡️) then return 1, 0
  end
  return 0, 0
end
function draw_sprite_rotated(sprite_id, position, size, theta, is_opaque)
  local sx, sy = (sprite_id % 16) * 8, (sprite_id \ 16) * 8 
  local sine, cosine = sin(theta / 360), cos(theta / 360)
  local shift = size\2 - 0.5
  for mx=0, size-1 do 
    for my=0, size-1 do 
      local dx, dy = mx-shift, my-shift
      local xx = flr(dx*cosine-dy*sine+shift)
      local yy = flr(dx*sine+dy*cosine+shift)
      if xx >= 0 and xx < size and yy >= 0 and yy < size then
        local id = sget(sx+xx, sy+yy)
        if id ~= global_data_table.palettes.transparent_color_id or is_opaque then 
          pset(position.x+mx, position.y+my, id)
        end
      end
    end
  end
end
function longest_string(strings)
  local len = 0
  for string in all(strings) do 
    len = max(len, #string)
  end
  return len
end
function round_to(value, place)
  local mult = 10^(place or 0)
  return flr(value * mult + 0.5) / mult
end
function table_contains(table, val)
  for obj in all(table) do 
    if (obj == val) return true
  end
end
function get_array_entry(table, name)
  for entry in all(table) do 
    if (entry.name == name) return entry
  end
end
function combine_and_unpack(data1, data2)
  local data = {}
  for dat in all(data1) do
    add(data, dat)
  end
  for dat in all(data2) do
    add(data, dat)
  end
  return unpack(data)
end
function pretty_print(text_data, width)
  local max_len= flr(width/5)
  local counter, buffer = max_len, ""
  for _, word in pairs(split(text_data, " ")) do
    if #word + 1 <= counter then 
      buffer ..= word.." "
      counter -= #word + 1
    elseif #word <= counter then 
      buffer ..= word
      counter -= #word 
    else
      buffer ..= "\n"..word.." "
      counter = max_len - #word + 1 
    end
  end
  return buffer
end
function save_byte(address, value)
  poke(address, value)
  return address + 1
end
function save_byte2(address, value)
  poke2(address, value)
  return address + 2
end
function encode_rod_inventory()
  local bits = 0
  for i, rod in pairs(global_data_table.rods) do 
    if table_contains(rod_inventory, rod) then 
      bits |= (1 << (i-1))
    end
  end
  return bits
end
function decode_rod_inventory(bits)
  local rods = {}
  for i, rod in pairs(global_data_table.rods) do 
    if (bits & (1 << (i-1))) > 0 then 
      add(rods, rod)
    end
  end
  return rods
end
function unpack_table(str)
  local table,start,stack,i={},1,0,1
  while i <= #str do
    if str[i]=="{" then 
      stack+=1
    elseif str[i]=="}"then 
      stack-=1
      if(stack>0)goto unpack_table_continue
      insert_key_val(sub(str,start,i), table)
      start=i+1
      if(i+2>#str)goto unpack_table_continue
      start+=1
      i+=1
    elseif stack==0 then
      if str[i]=="," then
        insert_key_val(sub(str,start,i-1), table)
        start=i+1
      elseif i==#str then 
        insert_key_val(sub(str, start), table)
      end
    end
    ::unpack_table_continue::
    i+=1
  end
  return table
end
function insert_key_val(str, table)
  local key, val = split_key_value_str(str)
  if key == nil then
    add(table, val)
  else  
    local value
    if val[1] == "{" and val[-1] == "}" then 
      value = unpack_table(sub(val, 2, #val-1))
    elseif val == "True" then 
      value = true 
    elseif val == "False" then 
      value = false 
    else
      value = tonum(val) or val
    end
    if value == "inf" then 
      value = 32767
    end
    table[key] = value
  end
end
function convert_to_array_or_table(str)
  local internal = sub(str, 2, #str-1)
  if (str_contains_char(internal, "{")) return unpack_table(internal) 
  if (not str_contains_char(internal, "=")) return split(internal, ",", true) 
  return unpack_table(internal)
end
function split_key_value_str(str)
  local parts = split(str, "=")
  local key = tonum(parts[1]) or parts[1]
  if str[1] == "{" and str[-1] == "}" then 
    return nil, convert_to_array_or_table(str)
  end
  local val = sub(str, #(tostr(key))+2)
  if val[1] == "{" and val[-1] == "}" then 
    return key, convert_to_array_or_table(val)
  end
  return key, val
end
function str_contains_char(str, char)
  for i=1, #str do
    if (str[i] == char) return true
  end
end
function hex2num(str)
  return ("0x"..str)+0
end
function load_stored_gfx(gfx)
  local index=8192
  for i=1,#gfx,2 do
    local count=hex2num(sub(gfx,i,i))
    local col=hex2num(sub(gfx,i+1,i+1))
    for j=1,count do
      sset(index%128,index\128,col)
      index+=1
    end
  end
end
function title_loop()
  run(boid_array)
  Animator.update(cat)
  
  if btnp(❎) then
    Menu.invoke(get_active_menu())
  end
  if (btnp(🅾️)) sfx(4)
end
function credits_loop()
  if btnp(🅾️) then
    sfx(60)
    load_area_state("title", -3)
  end
  if btnp(❎) then
    local meows = {1, 3, 5}
    sfx(meows[flr(rnd(3))+1])
  end
  for i=1, #credit_y_offsets do 
    credit_y_offsets[i] -= 1
    if credit_y_offsets[i] <= -15 then 
      credit_y_offsets[i] = 340
    end
  end
end
function map_loop()
  if btnp(🅾️) then
    local menu = get_active_menu()
    if menu and menu.prev then 
      swap_menu_context(menu.prev)
      sfx(60)
    end
  end
  if btnp(❎) then
    Menu.invoke(get_active_menu())
  end
end
function shop_loop()
  local menu = get_active_menu()
  if show_rod_shop then
    rod_shop_loop()
  end
  if btnp(🅾️) then
    if show_rod_shop then
      show_rod_shop = false
      get_menu("shop").enable = true
    else 
      load_area_state("main", -1)
    end
    sfx(60)
  end
  if btnp(❎) and not show_rod_details then
    Menu.invoke(menu)
  end
end
function fish_loop()
  Animator.update(cat)
  if btnp(🅾️) then
    if (fishing_areas[loaded_area].state == "detail") return
    if get_active_menu() == nil then 
      get_menu("fishing").enable = true
    else
      swap_menu_context(get_active_menu().prev)
    end
    sfx(60)
  end
  
  if get_active_menu() == nil then
    FishingArea.update(fishing_areas[loaded_area])
  elseif btnp(❎) then
    Menu.invoke(get_active_menu())
  end
end
function compendium_loop()
  if btnp(🅾️) then
    if show_fish_details then 
      show_fish_details, fish_detail_flag = false
    else 
      loaded_area = -1
      get_menu("main").enable, fish_detail_flag = true
    end
    sfx(60)
    return
  end
  if not show_fish_details then
    if btnp(❎) and not Inventory.check_if_hidden(fishpedia) and fish_detail_flag then
      show_fish_details = true
      return
    end
    fish_detail_flag = true
    Inventory.update(fishpedia)
  end
end
function rod_shop_loop()
  if (show_rod_details) return
  if btnp(❎) and not Inventory.check_if_disabled(rod_shop) then
    local rod = global_data_table.rods[rod_shop.pos + 1]
    if (rod.cost > cash) return
    sfx(7)
    add(rod_inventory, rod)
    Inventory.get_entry(rod_shop, rod_shop.pos).is_disabled = true
    Menu.update_content(get_menu("switch_rods"), switch_rods_menu())
    cash -= rod.cost
    return
  end
  Inventory.update(rod_shop)
end
function draw_title()
  foreach(boid_array, Boid.draw)
  Animator.draw(cat, 64, 50)
end
function draw_credits()
  print_with_outline("credits", 47, credit_y_offsets[1], 7, 1)
  print_with_outline("project developers", 25, credit_y_offsets[2], 7, 1)
  print_with_outline("michael:\n  • game director\n  • game designer", 10, credit_y_offsets[3], 7, 1)
  print_with_outline("jeren:\n  • programmer\n  • fish artist", 10, credit_y_offsets[4], 7, 1)
  print_with_outline("kaoushik:\n  • programmer\n  • rod artist", 10, credit_y_offsets[5], 7, 1)
  print_with_outline("nick:\n  • background artist", 10, credit_y_offsets[6], 7, 1)
  print_with_outline("siyuan:\n  • fish art designer\n  • cat artist", 10, credit_y_offsets[7], 7, 1)
  print_with_outline("alex:\n  • sound engineer", 10, credit_y_offsets[8], 7, 1)
  print_with_outline("katie:\n  • music engineer", 10, credit_y_offsets[9], 7, 1)
  print_with_outline("external developers", 25, credit_y_offsets[10], 7, 1)
  print_with_outline("jihem:\n  • created the rotation\n    sprite draw function", 10, credit_y_offsets[11], 7, 1)
  print_with_outline("daniel shiffman:\n  • js boids implementation", 10, credit_y_offsets[12], 7, 1)
  print_with_outline("mhughson:\n  • additional sprite\n    memory loading", 10, credit_y_offsets[13], 7, 1)
end
function draw_map()
  print_with_outline("press ❎ to select", 1, 114, 7, 1)
  if get_active_menu().prev then
    print_with_outline("press 🅾️ to return", 1, 122, 7, 1)
  end
end
function draw_shop()
  map(0, 0, 0, 0)
  print_with_outline("cash: "..cash, 1, 1, 7, 1)
  spr(shopkeeper.sprite, 48, 40, 2, 2)
  if show_rod_shop then
    draw_rod_shop()
    if get_active_menu() ~= nil then
      get_active_menu().enable = false
    end
  end
  if get_active_menu() ~= nil then 
    print_with_outline("press ❎ to select", 1, 114, 7, 1)
  end
end
function draw_fishing()
  map(0, 0, 29, 24)
  local pos = global_data_table.areas[loaded_area].position
  Animator.draw(cat, pos[1], pos[2])
  
  local border_rect = BorderRect:new(
    Vec:new(4, 44),
    Vec:new(18,18),
    7, 14, 2)
  BorderRect.draw(border_rect)
    
  spr(current_rod.spriteID, 7, 46, 2, 2)
  if get_active_menu() ~= nil then 
    print_with_outline("press ❎ to select", 1, 114, 7, 1)
  elseif (fishing_areas[loaded_area].state ~= "detail") then
    print_with_outline("press ❎ to fish", 1, 114, 7, 1)
    print_with_outline("press 🅾️ to open option menu", 1, 120, 7, 1)
  end
  FishingArea.draw(fishing_areas[loaded_area])
end
function draw_compendium()
  if show_fish_details then 
    draw_fish_compendium_entry(fishpedia.data[fishpedia.pos])
  else
    Inventory.draw(fishpedia)
  end
end
function draw_fish_compendium_entry(fish_entry)
  BorderRect.draw(compendium_rect)
  BorderRect.draw(compendium_sprite_rect)
  local sprite_pos = compendium_sprite_rect.position + Vec:new(4, 4)
  spr(
    fish_entry.sprite_id, 
    combine_and_unpack(
      {Vec.unpack(sprite_pos)},
      {2, 2}
    )
  )
  local detail_pos = compendium_sprite_rect.position.x + compendium_sprite_rect.size.x + 2
  print_with_outline(
    fish_entry.name, 
    detail_pos, compendium_sprite_rect.position.y,
    7, 0
  )
  print_with_outline(
    "weight: "..fish_entry.data.weight..fish_entry.data.units[2], 
    detail_pos, compendium_sprite_rect.position.y + 12,
    7, 0
  )
  print_with_outline(
    "size: "..fish_entry.data.size..fish_entry.data.units[1], 
    detail_pos, compendium_sprite_rect.position.y + 19,
    7, 0
  )
  local stars = ""
  for i=1, fish_entry.data.rarity do 
    stars ..= "★"
  end
  local lines = split(pretty_print(
    fish_entry.data.description,
    compendium_rect.size.x - 8 
  ), "\n")
  local y_offset = compendium_sprite_rect.position.y + compendium_sprite_rect.size.y
  print_with_outline(
    stars,
    compendium_rect.position.x + 4,
    y_offset-8,
    10, 7
  )
  for i, line in pairs(lines) do 
    print_with_outline(
      line, 
      compendium_rect.position.x + 4,
      y_offset + (i-1) * 7,
      7, 0
    )
  end
end
function draw_rod_shop()
  Inventory.draw(rod_shop)
  rod_description(rod_shop.pos + 1)
end
function rod_description(pos, draw_pos)
  local rod = global_data_table.rods[pos]
  if(rod == nil) return
  description_pos = Vec:new(3, 75)
  local border_rect = BorderRect:new(
    description_pos,
    Vec:new(122, 50),
    7, 8, 2)
  BorderRect.draw(border_rect)
  print_with_outline(rod.name..": "..(Inventory.check_if_disabled(rod_shop) and "(owned)" or ""), description_pos.x + 2, description_pos.y + 2, 7, 0)
  local color = 3
  if Inventory.check_if_disabled(rod_shop) or rod.cost > cash then 
    color = 2
  end
  print_with_outline("cost: "..rod.cost, description_pos.x + 2, description_pos.y + 12, color, 0)
  
  print_with_outline("power: "..rod.power, description_pos.x + 80, description_pos.y + 12, 7, 0)
  print_with_outline(pretty_print(rod.description, 140), description_pos.x + 2, description_pos.y + 22, 7, 0)
end
__gfx__
11221122112211220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
112211221122112200000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000000000000000
22112211221122110000000000000000000000000000000000000a440a0000000000000000000000000000000000000000000000000000000000000044400000
22112211221122110000004888000000000000999000000000a444a44400a0000000000111000000000000666600000000000000770000000000004444000000
112211221122112200004888800000480000999000000000004a444a444a000000000091f0000000000066666660005500000007660000000000055555400000
11221122112211220048889900004889000555555000009904144a44dd440004000019ffff10001000dd55555600055500000111111000060005555555540044
221122112211221108a899999008899000555599555009704114444d554a4014006711fff11106110d1555555550555000111666661100660555666665550444
22112211221122118a5a9999998899005519999999959700444a44d55444a1441111111111111771d55555555595550011d66666666617765516677776664440
112211221122112288a9999999999000999777777777700044a44455544444441115555551171171665995559966550067777766667777776677777777776444
112211221122112288999999999999000677777776009700a944a445554a4094dd76666661711771666699996600d55000777777777700770747777777740044
221122112211221109999999aa0999900006667990000970099994a45544a00900ddd71667dd07110066666665000dd500066777776600070044477774444000
2211221122112211009999aaa00099aa0000990099900099a0f999999a9000000000dd766d00001000055500d55000dd00006600066000000004400000440000
112211221122112200099aaa00000099000000000000000000affaff99a00000000000dd70000000000055000dd0000000000000000000000000000000000000
1122112211221122000000000000000000000000000000000000ffaf0a0000000000000000000000000000000000000000000000000000000000000000000000
22112211221122110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22112211221122110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07770000000000008880000000000888000007777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000
74447700000770008000000000000008000076666667000000000000000000000000000000000000000000000000000000000000000000000000000000000000
074444700074470080000000000000080007666666667000000000000000000000000000dd60000000000000336000000000000bbbbb00000000000000000000
0074444707444470000000000000000000076666666667000000000000000000000000d6660000000000003366600000000000b3333300000000000000000000
00744447744444470000000000000000000766667666670000000000000000000000015151600000000011116630000000001111133000000000055550000000
0744447074477447000000000000000000007667766667000000004440000000000515515556002d001113311100033600113111110000000000555500000001
7444770007700770000000000000000000000770076667000005555555400044015515555551022d01133f6333003366111b3133131001bb0001111111550114
077700000000000000000000000000000000000076667000555222222255544055855515515122d01433f66f6f333360b4b331311331133b11d44444444441d0
00000000000000000000000000000000000000076667000061eeeeeee6ddd40066255155515512dd33366666666f33606bb3133333ff33309999ffffffff11d0
0000000007700770000000000000000000000076667000006ff6666666fff440027771551776002d733777666670336666611313fff003330000fffffff00114
000000007447744700000000000000000000000777000000009fffffff900044006667777666600007777666770003360fffffffff600bbb0000000000000004
00000000744444470000000000000000000000000000000000009900999000000006600000660000007777777f3000000fffffff666300000000000000000000
000000000744447000000000000000000000000777000000000000000000000000000000000000000000007f663000000033600633bb00000000000000000000
00000000007447008000000000000008000000766670000000000000000000000000000000000000000000063000000000633600000000000000000000000000
00000000000770008000000000000008000000766670000000000000000000000000000000000000000000000000000000063b00000000000000000000000000
00000000000000008880000000000888000000077700000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000088880000000000000000000000000000000000000000000000000000000000
00000000000000000000000056600000000000000000000000000000000000000899998880000000000000000000000000000000000000000000000000000000
000000000000000000000000066600000000000000000000000000000000000089aaaa9980000000000000000000000000000000000000000000000000000000
0000000000000000000000000566600000000000000000000000000000000000aa3333aa8800000000000000000000000000002cc00000000000000000000000
00000000000000000000655500556600000000000000000000000a616000000033dd333aa0000048000000000000000000000cc2200000900000000000000000
000000000000000f0006666655556600000061616555000500089961960001779111ddd3000048890066606006000660009c999c900009990000066600000000
00000dffff0000fd006165666666660000055555115006650819a7711988677701a11113900889900665605605606600919c9c9c9900c9900000444440000600
dfff1fffdfffdfff0666656666666660551ddddddd55655008977777199877708a5a9919998899000666666666666000999c9c9999c2c9000044999944406600
66666666666600fd07766666666666607755555555575500066119997aa7167788a99999999990000666600600606600999c9c99c99c29000461666699ff6000
0000ff6666ff000d007766666677776000067676767055500009998877000167889999999999990000666060060006600999c999c900c9900ffff666ff006600
00000ff0000ff00000077777777776000000550005500000000680006660000009999999aa099990000000000000000000c9c992c2000999000ffffff0000600
0000000000000000000077770055660000000000000000000000000000000000009999aaa00099aa000000000000000000cc000c2cc000900000660000000000
000000000000000000000000056660000000000000000000000000000000000000099aaa000000990000000000000000000000002cc000000000000000000000
00000000000000000000000006660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000056600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006600000000000000000000000000066000000000000000000000000000000000000000000000000000000000044444444440000000000000000000
000000006667000000000000000000000000066677000000000000000000000000000000000000000000000000000000004aaaaaaaaaa4000000000000000000
000aa006677700000000000000000000000066777700666000000000000000000000000000000000000000000000000004aaaaaaaaaaaa400000000000000000
0aaaa04888770660000000488800000000006748866777700000000000000000000000dddd00000000000000000000004aaa88aa88aaaaa40000000000000000
aa004888866666780000488885150048000668866777777800000000000000000000ddddd00000dd00000055000000004aaa88aa88aaa884009ff90000000fff
0048889667777779055588995555588900a8889677777779000000002222000000ddddcc0000dddd00000555000000554aaccccccccaa5840ff990000000f000
08a899667777777058a85999455559900a5a99677777779000055555555200220dadccccc00ddcc000011115511005554ac9cccccccc55a4ff9f09ff1f0f9990
8a5a9677777777705a5a555444855900a515a999977799005555222555555220da5accccccddcc005115555555511f504a77777777775aa4999ffff999f00000
88a999777777977058a9544599999000a515a999999990002152222222222200ddacccccccccc0005256655555555f504aa66677776655a4999999999fffffff
889999999999990085554499999999008a5a9999999999002252222222255220ddcccccccccccc004446555555fff5504aaaaaaa88aaa5a49ff90ff91f0f0000
09999999aa09999007944919aa09999009a999966a09999000eeeeeee55000220cccccccdd0cccc000f4ffffffd005554aaaaaaa88aa88a409fff0000000fff0
009999aaa00099aa00449111a00099aa009999a7660099aa000022002220000000ccccddd000ccdd0000dd00ddd000554a88a88aaaaa88a40099ff00000000ff
00099aaa00000099000911a11000009900099aa7766000990000000000000000000ccddd000000dd00000000000000004a88a88aaaaaaaa40000000000000000
00000000000000000000100010000000000060007766000000000000000000000000000000000000000000000000000004aaaaaaa88aaa400000000000000000
000000000000000000000000000000000000760077760000000000000000000000000000000000000000000000000000004aaaaaa88aa4000000000000000000
00000000000000000000000000000000000077600070000000000000000000000000000000000000000000000000000000044444444440000000000000000000
9999999999999999999999999999999999999999999999999999999999999999771111111111cccc77111111111111ccc77111111ccc77ffffffffffffffffff
999999999999999999999999999999999999999999999999999999999999999911111111111ccc7711111111111111cc77111111ccc77fffffffffffffffff4f
999999999999999999999999999999999999999999999999999999999999999911111111cccc771111111111111111c71111111cccc7ffffff4ffffffff4ffff
999999999999999999999999999999999999999999999999999999999999999911111111cc77711111111111111111771111111ccc7fffffffffffffffffffff
999999999999999999999999999999999999999999999999999999999999999911111111777111111111111111111111111111ccc77fffff4fffffffffffffff
999999999999999999999999999999999999999999999999999999999999999911111111111111111111111111111111111111ccc7ffffffffffffffffffffff
99999999999999999999999999999999999999999999999999999999999999991111111111111111111111111111111111111cccc7ffffffffff4fffffffffff
99999999999999999999999999999999999999999999999999999999999999991111111111111111c7111111111111111111cccc77ff4fffffffffffffffffff
9999999999999999999999999999999999999999999999999999999999999999111111111111111cc7111111111111111111ccc77ffffffffffffffffff4ffff
999999999999999999999999999999999999999999999999999999999999999911111111111111ccc711111111111111111cccc7ffffffffffffffffffffffff
99999999999999999999999999999999999999999999999999999999999999991111111111111ccc7711111111111111111ccc77ffffffffffff4fffffffffff
9999999999999999999999999999999999999999999999999999999999999999111111111111ccc771111111111111111cccc77fffffffffffffffffffffffff
999999999999999999999999999999999999999999999999999999999999999911111111111cccc711111111111111cccccc77fff4ffffffffffffffffffffff
9999999999999999999999999999999999999999999999999999999999999999111111111ccccc7711111111111ccccccc777fffffffffffffffffffffffffff
9999999999999999999999999999999999999999999999999999999999999999111ccccccccc7771111111111cccccc7777ffffffffffffffffffffffffff4ff
999999999999999999999999999999999999999999999999999999999999999911ccccccc777711111111111ccccc77fffffffffffffffffffffffffffffffff
9999999999aaaaaa9999999999999999999999999999999999999999999999991ccc7777771111111111111ccccc77ffffffffffffffffffffffffffffffffff
99999999aaaaaaaaaa9999999999999999999999999999999999999999999999ccc77111111111111111111cccc77ffffffffffffffffffff4ffffffffffffff
9999999aaaaaaaaaaaa999999999999999999999999999999999999999999999cc77111111111111111111cccc7fffffffffffffffffffffffffffffffffffff
9e9e9eaaaaaaaaaaaaaa9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e777111111111111111111cccc77fffffffffffffffffffffffffffffffffffff
e9e9eaaaaaaaaaaaaaaaa9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e911111111111111111111cccc77ffffffffffffffffffffffffffffffffffffff
9e9e9aaaaaaaaaaaaaaaae9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e1111111111111111111cccc77fffffffff4fffffffffffffffffffffffffffff
eeeeaaaaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee111111111111cccccccccc77ffffffffffffffffffffffffffffffffffffffff
e2e2aaaaaaaaaaaaaaaaaae2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e21111111111cccccccccc777fffffffffffffffffffffffffffffffff4fffffff
2e2eaaaaaaaaaaaaaaaaaa2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e11111111cccccc7777777fffffff4fffffffffff4fffffffffffffffffffffff
2222aaaaaaaaaaaaaaaaaa222222222222222222222222222222222222222222111111cccccc777fffffffffffffffffffffffffffffffffffffffffffffffff
11111111111111111111111111111111111111cc711111ccc7fff4ffffffffffccccccccc7777fffffffffffffffffffffffffffffffffffffffffffffffffff
1111cc7111111111111111111111111111111ccc71111ccc77ffffff4fffffffccccccc777ffffffffffffffffffffffffffffffffffffffffffffffffffffff
111ccc7111111111111111cc711111111111ccc77111cccc7f4ff4ffffff4fff77777777ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
11cc77111111111111cccccc7111111111cccc77111cccc77ffffff4ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ccc771111111111ccccccc7771111111cccc777111ccc77ff4ffffffff4ffffffff4fffffffffffffffffffffffff4ffffffffffffffffffffffffffffff4fff
cc771111111111cccc7777711111111ccc77711111ccc7ffffff4ffffffffffffffffffffffffff4ffffffffffffffffffffffffffffffffff4fffffffffffff
0000000000000000000000000000000000000000000000008800000000000088000000000004000000000000000d000000000000000b00000000000000090000
000000000000000000000000000000000000000000000000888000000000088800000000004440000000000000d5d0000000000000b3b00000000000009a9000
00000000000000000000000000000000000000000000000008880000000088800000000004944000000000000d55d000000000000b33b0000000000009aa9000
0000000000000000000000000000000000000000000000000088800000088800000000004444600000000000d55d600000000000b33b3000000000009aa96000
000000000000000000000000000000000000000000000000000888000088800000000004444060000000000d55d060000000000b33b0300000000009aa906000
00000000000000000000000000000000000000000000000000008880088800000000004444006000000000d55d006000000000b33b0030000000009aa9006000
0000000000000000000000000000000000000000000000000000088888800000000004454000600000000d55d000600000000b33b0003000000009aa90006000
000000000000000000000000000000000000000000000000000000888800000000004444000006000000d55d000060000000b33b0000300000009aa900006000
00000000000000000000000000000000000000000000000000000088880000000004494000000600000d55d000006000000b33b0000030000009aa9000006000
0000000000000000000000000000000000000000000000000000088888800000004444000000060000d55d000000600000b33b0000003000009aa90000006000
000000000000000000000000000000000000000000000000000088800888000004444000000006000d56d000000060000b31b0000000300009a2900000006000
00000000000000000000000000000000000000000000000000088800008880004444000000000600d561600000006000b31c1000000030009a2e200000006000
00000000000000000000000000000000000000000000000000888000000888004540000000000600d5d6000000006500b3b1000000003b009a92000000006d00
000000000000000000000000000000000000000000000000088800000000888044000000000000600d000000000005000b00000000000b000900000000000d00
000000000000000000000000000000000000000000000000888000000000088800000000000000600000000000005500000000000000bb00000000000000dd00
00000000000000000000000000000000000000000000000088000000000000880000000000000060000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000007700000000050000500000000005000050000000000000000000000000060000600000000
00000000000000000000000000000000000000000000000000000776666000000565005650000000056500565000000000000000000000000676006760000000
00000000000000000000000000000000000000000000000000066665555663300566556650000000056655665000000000000000000000000677667760000000
00000000000000000000000000000000000000000000000000335555555555305666666665000000566666666500000000000000000000006777077776000000
000000000000000000000000000000000000000000000000003366666ddddd005666666665000000566666666500000000000000000000006777707776000000
0000000000000000000000000000000000000000000000000033d665566533005c6666c6650000005c6666c66500000000000000000000006797770076000000
000000000000000000000000000000000000000000000000003d36655665d3305c6666c6650000005c6666c66500000000000000000000006797770076000000
000000000000000000000000000000000000000000000000003d33655665d3305e66666e650055005e66666e6500055000000000000000006777777706006600
000000000000000000000000000000000000000000000000000d33355665d3000556666550056650055566655000566500008080000000000667777660067760
000000000000000000000000000000000000000000000000000d56655665d000000666666505665056655666650056650080080000a0a0a00067777776067760
000000000000000000000000000000000000000000000000000d56655665d000566556666650566505566666665005650008000000a0a0a00067777777606776
000000000000000000000000000000000000000000000000000d56655665d000055666556650566500055566665055650080088000a0a0a00067676677606776
000000000000000000000000000000000000000000000000000d56655665d0000005556656556665000005556655666500000800000000000067667767667776
000000000000000000000000000000000000000000000000000d566556653000000005666656665000000566565666500000000000a0a0a00067667777677760
000000000000000000000000000000000000000000000000000d5665566533000000566666565500000056666656550000000000000000000067677777676600
00000000000000000000000000000000000000000000000000055665566553000000555555550000000055555555000000000000000000000006666666660000
__map__
8081828384858687000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9091929394959697000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a0a1a2a3a4a5a6a7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b0b1b2b3b4b5b6b7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88898a8b8c8d8e8f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
98999a9b9c9d9e9f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a8a9aaabacadaeaf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b8b9babbbcbdbebf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000200000e150111501315013150101500d1500a1500a1500b1500c1500e15010150111500d1500a1500b1500d1500e1500f1500a150081500a1500d1500e150101500a1500a1500b1500d1500f150101500e150
00030000298702c8702e8702f87030870308702d8702a87025870218701d87016870108700b87007870008700f800078000580000800008000080000800008000080000800008000080000800008000080000800
541000200061000611006110161102611036110462105621066310763108631096410a6510a6510a6510966108661076610566104651036410263102631016310062100621006210061100611006110061100610
0003000025856288562b8562f856338563685635856318562c856288562485624856288562b8563085633856238062480625806288062c8063080630806338062580633806258063380625806338062580633806
000300000285005850078500885009850088500885009850098500985009850098500985009850098500985008850088500784006840058400583004830028200181000810028000180001801008010080100801
000a0000328502c8510c000268000c000208000c000198000c000128000c0000c8000c000078000c000028000c0000c0000c0000c0000c0020c0020c0020c0022400024000240002400024002240022400224002
170a0000240502605028050240522305024050060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000400102001000010a001
170b000024050280502b050280502b050300500c0000c0000c0000c0000c0000c0000c0000c0000c0000c00008000090000900009000090000900009000090000900009000090000900009000090000900009000
910a00000c645000000c6450000024640136151864007615186400c60024640136151864013615186400c60000645000000064500000306401f61524640136152464018600306401361518640076151864018600
910a000018173000000c6450000018173136151864007615181730c60024640136151817313615186400c60018173000000064500000181731f61524640136151817318600306401361518173076151864018600
910a00001817300000181730000018173136151817307615181730c60018173136151817313615181730c60018173181731817318173181731817318173181731817318173181731817318173181731817318173
910a000018173000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001e1001e1600c1611d160211612316026161181733064124631186210c611
510a0000124601246506464124641846418415153641e3641e365154641e3641e365154641e3641846418465123601236506364123641846418415154641e4641e465154641e4641e465154641e4641846418415
510a00001e4601e455124641e4642446424415213642a3642a365214642a3642a365214642a36424464244651e3601e365123641e3642446424415214642a4642a465214642a4642a465214642a4642446424465
510a00001e360123641e3642136421365123651e364283642836512365283642836527365123641e3641e3651e360123641e3642836428365123601e364273642736517365273642736527365283642736427365
510a00001e340123441e3442134421345123451e344283442834512345283442834527345123441e3441e3452a345123441e3442d3442d34512345283442f3442f3451b3452f3442f3452f3402d3452a34025345
510a00001e365123641e3642136421365123651e364283642836512365283642836527365123641e3641e3651e300123001e3002830028300123001e300273002730017300273002730027300283002730027300
b90500083130031300313003130031314313203133031340000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b90a00003130000000000001e4301e435124341e3342433424315214342a4342a435214342a4342a435214342a43424334243351e4301e430124341e4342443424415214342a3342a335213342a4342a43521434
b90a00002a43424334243151e4301e435124341e3342433424315214342a4342a435214342a4342a435214342a43424334243351e4301e435124341e4342443424415214342a3342a335213342a4342a43521434
b90a00001e44512445124452a44512445124451e44512445124452a44512445124451e44512445124452a44512445124451e44512445124452a44512445124452344517445174452744517445174452344517445
b90a00001e46512465124652536425365124651e4652d3642d3652a4652d3642d3652a365124602d3642d36512465124651e4652d3642d3652a465124652a3642a365174652a3642a3652f3602d3642f3642f365
b90a00001e46512465124653136431365124652d36431364313652a36531364313652a3651236031364313652d3002d3002a400124002a3002a300174002a3002a3002f3002d3002f3002f300000000000000000
a90500082a0002a000000000000012060120601206012060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a90a00002a0002a0001206012060000000000012060120600000000000120601206000000000001206012060000000000012060120600000000000120601206000000000000b0600b06000000000000b0600b060
a90a00002a0002a00012060120601200012000120601206000000000001206012060000000000012060120601b1601e1651216512165171601b165121651216510160101600d1600d16012160121600616006160
a90a00001b1401e1451214512145171401b145121451214510140101400d1400d1401214012140061400614000000000000000000000000000000000000000000000000000000000000000000000000000000000
910a0004183730000024640196112460018600136001960018200246001f60019600246001860013600000001820018600000000000030600246001f600196001820018600136000000024600186000000000000
910a000018373000002464019611183730000024640196111837300000246401961118373000002464018373183731f6001960018200186001360000000246001860000000000000000000000000000000000000
811400001e2421e2421e2421e2421e2421e2421e2421e2421e2421e2421e2421e2421e2421e2421e2421e2420c2420c2420c2420c2420c2420c2420c2420c2420c2420c2420c2420c2420c2420c2420c2420c242
81141e001e2421e2421e2421e2421e2421e2421e2421e2421e2421e2421e2421e2421e2421e2421e2421e24218242182421824218242182421824218242182421824218242182421824218242182421820000000
800a06001844318443183431820018200182001840018200184000000018300182001820018200184001820018400000001830018200182001820018400182001840000000000000000018300000000000000000
a80500002a0402904128041270412604125041240412204121041200411e0411d0411c0411b0411a04119041180411604115041140411204111041100410f0410e0410d0410c0410a04109041080410604105041
910a00003c67024671186611066107661006510c6511f6512b641366413c6412b631366313c6312b62136621396213c6212b611366113c6150000000000000000000000000000000000000000000000000000000
810a0010182431e2421e2421e242183431e2421e2421e2421e2421e242183431e2421e2421e2421e2421e242182001e2001e2001e200183001e2001e2001e2001e2001e200183001e2001e2001e2001e2001e200
810a0010182430c2420c2420c242183430c2420c2420c2420c2420c242183430c2420c2420c2420c2420c2420c2000c2000c2000c200000000000000000000000000000000000000000000000000000000000000
810a00001824318242182421824218343182421824218242182421824218343182421824218242182421824218243182421824218242183431824218242182421824218242183431824218343182421834318343
b90a00001e3252032525325283252a3351e3352033525335283452a3451e3452034525355283552a3551e3652036525355283552a3551e3452034525345283452a3351e3352033525335283252a3252d32531325
b90a0000303252132524325283252a3352d335303352133524345283452a3452d345303552135524355283652a3652d355303552135524345283452a3452d345303352133524335283352a3252d3252a32524325
b90a00002a3252c3253132534325363352a3352c3353133534345363452a3452c3453135534355363552a3652c3653135534355363552a3452c3453134534345363352a3352c335313353432536325393253d325
c105002012030120300603106030060300603006030060301e03012031060310603006030060300603006030060300603006030060301e0301203106031060300603006030060300603006030060300603006030
c10500200c0300c030000310003000030000300003000030180300c03100031000300003000030000300003000030000300003000030180300c03100031000300003000030000300003000030000300003000030
510a00001e3252032525325283252a3351e3352033525335193501935019350193501935019350193521935221351213512135121351213502135021352213521e3511e3511e3511e3511e3501e3501e3521e352
510a00001c360103651b3601b36517350173551c350103551b3401b34517340173451c330103351b3301b33517320173251c320103251b3101b3151731017315303252132524325283252a3152d3152a31524315
510a00002a3252c3253132534325363352a3352c33531335193501935019350193501935019350193521935221351213512135121351213502135021352213522535125351253512535125350253502535225352
510a0000273502735027350273502735027350274522745228350283502835028350283502835028452284522a3512a3512a3512a3512a3502a3502a4522a4522f3512f3512f3512f3512f3502f3502f4522f452
811400011224212200122001220012200122001220012200122001e2001e2001e2001e2001e2001e2001e20018200182001820018200182001820018200182001820018200182001820018200182001820000000
510a00003136031360313603136031350313503135031350313403134031340313403133031330313303133031320313203132031320313103131031310313103131031310313103131031310313103131031310
810a00001c2401c2501c2501c2501a251192511825117251162512525025250252502525024251232512225121251212511e2001e200183001e2001e2001e2001e2001e200183001e2001e2001e2001e2001e200
0f050000001500015101151011510115102151031510415104151051510615106151071510815108151091510a1510b1510c1510c1510d1510e1510f151101511015111151121511315114151151511615117155
510a00001246012465064641246418464184151245012455064541245418454184151244012445064441244418444184151243012435064341243418434184151242012425064241242418424184150000000000
510a00001246012465064641246418464184151245012455064541245418454184151244012445064441244418444184151243012435064241241418400184001240012400064001240018400184000000000000
b90a00002a316343162a316343262a326343262a336343362a336343462a346343462a356343562a356343662a366343562a356343562a346343462a346343362a336343362a326343262a326343162a31634316
b90a00002531633316253163332625326333262533633336253363334625346333462535633356253563336625366333562535633356253463334625346333362533633336253263332625326333162531633316
a90a000012060120601206012060120601206012060120601206012060120601206012060120601206012060120601206012060120601206012060120601206012060120601206012060100610e0610c06116061
a90a00000b0600c0610c0600c0600c0600c0600c0600c0600c0600c0600c0600c0600c0600c0600c0600c0600c0600c0600c0600c0600c0620c0620c0620c0622406024060240602406024062240622406224062
a90a00002a0402a0401e060120620606006060060600606006060060600606006060060600606006060060600606006060060600606006060060600606006060060600606006060060600406102061000610a061
a80a00000b0600c0610c0600c0600c0600c0600c0600c0600c0600c0600c0600c0600c0600c0600c0600c06008060090610906009060090600906009060090600906009060090600906009060090600906009060
070800002405000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07080000240502b050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07080000240501d050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5704000033150351503815036150331502e1502a15026150221501d14018130141300e13009120041200011000110001000010000100001000010000100001000010000100001000010000100001000010000100
9203002035650396503d65039650366503765035650346503465036650396503a6503665035650386503b650376503365030650306503265033650306502b6502a6502e65037650316502f650326503a65034650
4f02000034250302502d2502925024250202501e2501a2501925017250162501a2501e25023250252502b2502e250302500000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 326c3608
00 32423708
00 32423808
00 32423908
00 32343609
00 32353709
00 3234380a
02 3342440b
01 0c11171b
00 0c11171b
00 0d12171b
00 0d13171b
00 0e14181b
00 0f14181b
00 0e15181b
02 1016191c
00 1d422021
00 1e42425f
00 1f42425f
01 22252808
00 23262908
00 22272808
00 24252908
00 222a2808
00 232b2908
00 222c2808
02 232d2908
00 2e2f2021
00 30424344
00 6e6f2021
00 41424344
00 41424344
00 41424344
00 41424344
00 60424244
00 41424344
00 5d424244
00 5d424244
00 67424244
02 5f424244
00 41424344
00 625d4244
00 40424244
00 42424244
00 42424244
00 42424244
00 42424244
00 42424244
00 42424244
00 42424244
00 42424244
00 42424244
00 42424244
00 42424244
00 42424244
00 42424244
00 42424244
00 42424244
00 42424244
00 42424244
00 42424244
00 42424244
00 42424244
00 42424244
