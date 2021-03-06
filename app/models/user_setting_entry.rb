class UserSettingEntry < ActiveRecord::Base
  belongs_to :setting, class_name: 'UserSetting', foreign_key: 'user_setting_id'

  serialize :value, Object
end
