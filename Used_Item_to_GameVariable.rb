#==============================================================================
# ** USED_ITEM_TO_GAMEVAR
#------------------------------------------------------------------------------
#  This code updates the consumption of items.
#  The unique id of the item used is recorded in a game variable
#
#  Author: Dev_With_Coffee (BossRpg)
#
#  It is not necessary to credit me as it is just a simple modification
#  Can be used in commercial and non-commercial games
#
#  Instruction:
#  To change the game variable in progress just call the following script:
#  USED_ITEM::VARID = NEWID
#
#  Example:
#  USED_ITEM::VARID = 20
#
#==============================================================================

module USED_ITEM
  #Put the variable id number
  VARID=1
end

class Scene_Item
  def update_target
    # If B button was pressed
    if Input.trigger?(Input::B)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # If unable to use because items ran out
      unless $game_party.item_can_use?(@item.id)
        # Remake item window contents
        @item_window.refresh
      end
      # Erase target window
      @item_window.active = true
      @target_window.visible = false
      @target_window.active = false
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      # If items are used up
      if $game_party.item_number(@item.id) == 0
        # Play buzzer SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # If target is all
      if @target_window.index == -1
        # Apply item effects to entire party
        used = false
        for i in $game_party.actors
          used |= i.item_effect(@item)
        end
      end
      # If single target
      if @target_window.index >= 0
        # Apply item use effects to target actor
        target = $game_party.actors[@target_window.index]
        used = target.item_effect(@item)
      end
      # If an item was used
      if used
        # Play item use SE
        $game_system.se_play(@item.menu_se)
        $game_variables[USED_ITEM::VARID]=@item.id
        # If consumable
        if @item.consumable
          # Decrease used items by 1
          $game_party.lose_item(@item.id, 1)
          # Redraw item window item
          @item_window.draw_item(@item_window.index)
        end
        # Remake target window contents
        @target_window.refresh
        # If all party members are dead
        if $game_party.all_dead?
          # Switch to game over screen
          $scene = Scene_Gameover.new
          return
        end
        # If common event ID is valid
        if @item.common_event_id > 0
          # Common event call reservation
          $game_temp.common_event_id = @item.common_event_id
          # Switch to map screen
          $scene = Scene_Map.new
          return
        end
      end
      # If item wasn't used
      unless used
        # Play buzzer SE
        $game_system.se_play($data_system.buzzer_se)
      end
      return
    end
  end
end