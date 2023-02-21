local global_data_str --[[remove]]
--[[json global_data_str ../data.json]]

function reset()
  global_data_table = unpack_table(global_data_str)
  -- debug_printh_table(global_data_table, "")
  menu_data = {
    {
      "main", nil,
      5, 70,
      {
        {
          text="shop", color={7, 0},
          callback=function()
            get_active_menu().enable = false
            loaded_area = 0
          end
        },
        { 
          text="fishing", color={7, 0}, 
          callback=function()
            get_active_menu().enable = false
            loaded_area = 1
          end
        }
      },
      nil,
      4, 7, 7, 3
    },
    {
      "fishing", nil,
      5, 70,
      {
        {
          text="return to map", color={7, 0},
          callback=function()
            swap_menu_context("main")
            loaded_area = -1
          end
        }
      },
      nil,
      4, 7, 7, 3
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
        }
      },
      nil,
      4, 7, 7, 3
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

  loaded_area = -1
end