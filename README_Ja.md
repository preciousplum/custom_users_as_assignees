# カスタムフィールドユーザの担当者化プラグイン
[English](README.md)

カスタムフィールドユーザにデフォルトクエリでの紹介やリマインダーメール送信する機能を追加するプラグインです。  
※「カスタムフィールドユーザ」とは、「ユーザ」フォーマットの「カスタムフィールド」で指定したユーザを指します。

レビューなど複数の作業者で同時進行するユースケースに必要な複数の担当者指定を実現できます。
  * カスタムフィールドユーザがチケットに追加また削除されたときに、そのユーザにメール通知されます。  
  チケット更新時、カスタムフィールドユーザに変更がない場合は、全カスタムフィールドユーザにもメール通知されます。(本来の動作としていずれの場合も作成者や担当者にも通知されます。)
  * カスタムフィールドユーザにもリマインダーメールが送信されます。
  * 「担当者」で指定された場合と同様に、チケットが検索されます。  
  例：「マイページ」＞「担当しているチケット」  
  ※元の「担当者」で検索したい場合は、"「担当者」のみ"のフィールドで検索してください。

## インストール方法

1. プラグインのインストール

    実行環境のRedmineパスの`plugins/custom_users_as_assignees`に対して`git clone`を実行してください。

        $ cd {RAILS_ROOT}/plugins
        $ git clone https://github.com/preciousplum/custom_users_as_assignees 

2. Redmineの再起動

    再起動後 **管理 > プラグイン** でこのプラグインが表示されます。  
    *) データベースのマイグレーションは必要ありません。 

## 互換性
原理的には、このプラグインはRedmine 3.3.0以降に対して互換性があります。
ただし、現状Redmine 3.4.5でしか動作確認されていません。

## 謝辞
このプラグインは notify_custom_users プラグインを元に開発しています。
https://github.com/Restream/notify_custom_users

## 画面イメージ
customfield_checkbox_utilityプラグインとともに使用した画面イメージです。
https://github.com/preciousplum/customfield_checkbox_utility

![カスタムフィールド設定](assets/images/custom_field_setting.png)  
![チケット編集](assets/images/edit_issue.png)  
![担当チケット](assets/images/assigned_to_me.png)  
![通知メール](assets/images/notification.png)  
![リマインダーメール](assets/images/reminder.png)  