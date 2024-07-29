#===============================================================================
# Restructures the trainer Pokemon editor so that plugins may add new properties.
#===============================================================================
module TrainerPokemonProperty
  #-----------------------------------------------------------------------------
  # Returns initial settings and associated keys for a trainer's Pokemon.
  #-----------------------------------------------------------------------------
  def self.editor_settings(initsetting)
    initsetting = {:species => nil, :level => 10} if !initsetting
    oldsetting = [
      initsetting[:species],
      initsetting[:level],
      initsetting[:real_name],
      initsetting[:form],
      initsetting[:gender],
      initsetting[:shininess],
      initsetting[:super_shininess],
      initsetting[:shadowness]
    ]
    keys = [
      :species, :level, :real_name, :form, :gender, 
      :shininess, :super_shininess, :shadowness
    ]
    Pokemon::MAX_MOVES.times do |i|
      oldsetting.push((initsetting[:moves]) ? initsetting[:moves][i] : nil)
      keys.push(:moves)
    end
    oldsetting.concat([
      initsetting[:ability],
      initsetting[:ability_index],
      initsetting[:item],
      initsetting[:nature],
      initsetting[:iv],
      initsetting[:ev],
      initsetting[:happiness],
      initsetting[:poke_ball]
    ])
    keys.push(
      :ability, :ability_index, :item, :nature,
      :iv, :ev, :happiness, :poke_ball
    )
    return oldsetting, keys
  end
  
  #-----------------------------------------------------------------------------
  # Returns all of the editor properties for a trainer's Pokemon.
  #-----------------------------------------------------------------------------
  def self.editor_properties(oldsetting)
    max_level = GameData::GrowthRate.max_level
    properties = [
      [_INTL("种类"),    SpeciesProperty,                     _INTL("宝可梦的种类")],
      [_INTL("等级"),      NonzeroLimitProperty.new(max_level), _INTL("宝可梦的等级(1-{1}).", max_level)],
      [_INTL("名字"),       StringProperty,                      _INTL("宝可梦的名称")],
      [_INTL("形态"),       LimitProperty2.new(999),             _INTL("宝可梦的形态")],
      [_INTL("性别"),     GenderProperty,                      _INTL("宝可梦的性别")],
      [_INTL("闪光"),      BooleanProperty2,                    _INTL("如果设置为true，则宝可梦是不同颜色的样子")],
      [_INTL("超闪光"), BooleanProperty2,                    _INTL("神奇宝贝是否超闪光（用特殊的闪光动画显示）")],
      [_INTL("阴影"),     BooleanProperty2,                    _INTL("如果设置为true，则宝可梦是阴影的宝可梦")]
    ]
    Pokemon::MAX_MOVES.times do |i|
      properties.push([_INTL("招式{1}", i + 1),
                       MovePropertyForSpecies.new(oldsetting), _INTL("宝可梦已学会的招式。所有招式留空（使用Z键删除）为野生招式配置。")])
    end
    properties.concat([
      [_INTL("特性"), AbilityProperty, _INTL("宝可梦的特性。覆盖特性索引。")],
      [_INTL("种族值"), LimitProperty2.new(99), _INTL("特性索引。0=第一个特性，1=第二个特性，2+=隐藏特性。")],
      [_INTL("持有物品"), ItemProperty, _INTL("宝可梦持有的物品。")],
      [_INTL("性格"), GameDataProperty.new(:Nature), _INTL("宝可梦的性格。")],
      [_INTL("个体值"), IVsProperty.new(Pokemon::IV_STAT_LIMIT), _INTL("宝可梦的个体值。")],
      [_INTL("基础点数"), EVsProperty.new(Pokemon::EV_STAT_LIMIT), _INTL("宝可梦的努力值。")],
      [_INTL("亲密度"), LimitProperty2.new(255), _INTL("宝可梦的亲密度（0-255）。")],
      [_INTL("精灵球"), BallProperty.new(oldsetting), _INTL("宝可梦被抓的精灵球类型。")],
    ])
    return properties
  end
  
  #-----------------------------------------------------------------------------
  # Rewritten editor for trainer's Pokemon.
  #-----------------------------------------------------------------------------
  def self.set(settingname, initsetting)
    oldsetting, keys = self.editor_settings(initsetting)
    pkmn_properties = self.editor_properties(oldsetting)
    pbPropertyList(settingname, oldsetting, pkmn_properties, false)
    return nil if !oldsetting[0]
    ret = {}
    keys.each_with_index do |key, i|
      case key
      when :moves
        ret[key] = [] if !ret[key]
        ret[key].push(oldsetting[i])
      else
        ret[key] = oldsetting[i]
      end
    end
    ret[:moves].uniq!
    ret[:moves].compact!
    return ret
  end
end