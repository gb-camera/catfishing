local global_data_str --[[remove]]
--[[json global_data_str ../data.json]]

function reset()
  global_data_table = unpack_table(global_data_str)
  -- debug_printh_table(global_data_table, "")
  inventory = {}
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
  local menu_palette = global_data_table.palettes.menu
  menu_data = {
    {
      "main", nil,
      5, 70,
      {
        {
          text="shop", color={7, 0}, callback=load_area, args={0}
        },
        { 
          text="fishing", color={7, 0}, callback=load_area, args={1}
        },
        {
          text="fishapedia", color={7, 0}, callback=load_area, args={-2}
        }
      },
      nil,
      unpack(menu_palette)
    },
    {
      "fishing", nil,
      5, 70,
      {
        {
          text="return to map", color={7, 0},
          callback=function()
            swap_menu_context("main")
            FishingArea.reset(global_data_table.areas[loaded_area])      
            loaded_area = -1
          end
        }
      },
      nil,
      unpack(menu_palette)
    },
    {
      "shop", nil,
      5, 70,
      {
        {
          text="return to map", color={7, 0},
          callback=function()
            swap_menu_context("main")
            loaded_area = -1
          end
        },
        { text="sell all fish", color={7, 0}, callback=sell_all_fish },
        {
          text="buy rods", color={7, 0},
          callback=swap_menu_context, 
          args={"rods"}
        }
      },
      nil,
      unpack(menu_palette)
    },
    {
      "rods", "shop", 5, 70, buy_rods_menu(), rod_description,
      unpack(menu_palette)
    }
  }
  menus = {}
  for data in all(menu_data) do 
    add(menus, Menu:new(unpack(data)))
  end
  fishing_areas = {}
  for area in all(global_data_table.areas) do
    add(fishing_areas, FishingArea:new(area))
  end
  
  show_fish_details, fish_detail_flag = false
  fishpedia = Inventory:new(34, 36, 
    Vec:new(5, 5), 30, 
    { Vec:new(8, 8), Vec:new(111, 111), 7, 5, 3 }
  )
  for i, area in pairs(global_data_table.areas) do 
    for j, fish in pairs(area.fishes) do 
      Inventory.add_entry(fishpedia, j-1 + (i-1) * 5, fish.stats[2], fish.stats[1], {})
    end
  end

  cash = 0
  loaded_area = -1
  get_menu("main").enable = true
end