# 系統需求規格書 (System Specifications)

- 要求／要求仕様
- 顧客要望 <br> Client request | アドミリンクサービスを利用したい <br> Client wants to use the AdminLink service.
## AGT.1
* 要求 <br> request
* ユーザーインターフェース（UI）を実装し、ユーザーによる設定変更、状態確認ができる事。 <br> Implement a user interface (UI) , so users can change settings and check the status.

- 理由 | ・アドミリンクの設定変更をしたい <br> ・アドミリンクの状態確認をしたい <br> Client wants to change settings. <br> Client wants to check the status.
- 説明 | 画面仕様はWebUI仕様書を参照 <br> Refer to the WebUI required specifications for screen specifications.
### AGT.1.0
* 要求 <br> request
* アドミリンクサービスに関するUIを言語設定で選択されている言語で表示する事。 <br> Displaying the UI related to AdminLink service in the language selected in the language settings.

- 理由 | アドミリンクサービスを利用するために必要なデバイス側UIを、言語設定で選択されている言語で表示したい。 <br> The device-side UI required to use the AdminLink service must be displayed in the language selected in the language settings.
- 説明
#### AGT.1.0.0
* ＜デバイスの Web UI を言語設定で選択されている言語で表示する＞ <br> ＜Display the device's web UI in the language selected in language settings＞

#### AGT.1.0.1
* □□□
* デバイスの言語設定で選択されている言語で、アドミリンク用のWebUIが表示されること。(日本語または英語) <br> WebUI for AdmiLink is displayed in the language selected in the device's language settings. (Japanese or English)

#### AGT.1.0.10
* ＜デバイスのUIメッセージを言語設定で選択されている言語で表示する＞ <br> ＜Display device UI messages in the language selected in language settings＞

#### AGT.1.0.11
* □□□
* Web UI上で表示するUIメッセージは、言語設定で選択されている言語で表示されること。(日本語または英語) <br> UI messages displayed on the Web UI must be displayed in the language selected in the language settings.(Japanese or English) <br>  <br> 「UI Message」シートを参照。 <br> See the 'UI Message' sheet.

#### AGT.1.0.20
* ＜デバイスのログを英語で表示する＞ <br> ＜The device's log message must be displayed in English.＞

#### AGT.1.0.21
* □□□
* 例外として、ログメッセージは英語で出力されること。 <br> As exception, the log message for AdminLink must be output in English. <br>  <br> 「Log Message」シートを参照。 <br> See the 'Log Message' sheet.

### AGT.1.1
* 要求 <br> request
* デバイスのWeb UIで、アドミリンクサービスへの登録状態を表示する事 <br> Display the registration status to the AdminLink service on the device's Web UI.

- 理由 | ・アドミリンクの登録状態を表示したい <br> Client wants to display the registration status to the AdminLink service.
- 説明
#### AGT.1.1.0
* ＜「システム情報」画面に登録状態を表示＞ <br> ＜The registration status is displayed on the "System Information" screen.＞

#### AGT.1.1.1
* □□□
* 「アドミリンク登録状態」項目に、アドミリンクサービスへの登録状態を表示する。 <br> The "AdminLink Registration Status" item displays the registration status to the AdminLink service. <br> アドミリンク機能が無効の場合：無効 <br> When the AdminLink function is disabled:Disabled <br> 未登録の場合：未登録 <br> If not registered:Unregistered <br> 登録済みの場合：登録済み <br> If already registered:Registered <br> エラーにより取得できていない場合：確認中 <br> If it is not possible to retrieve due to an error:Checking

### AGT.1.2
* 要求 <br> request
* デバイスのWeb UIで、アドミリンク用の設定画面を開ける事 <br> Open the AdminLink configuration screen on the device's Web UI

- 理由 | ・アドミリンクの設定変更をしたい <br> Client wants to change settings.
- 説明
#### AGT.1.2.0
* ＜基本設定画面を開く＞ <br> ＜Open the Basic Settings screen＞

#### AGT.1.2.1
* □□□
* デバイスのWeb UI で、アドミリンクメニューの「基本設定」を選択する事で、「基本設定画面」を開ける事。 <br> In the device's Web UI, select "Basic Settings" from the AdminLink menu to open the "basic settings page".

#### AGT.1.2.10
* ＜詳細設定画面を開く＞ <br> ＜Open the Advanced Settings screen.＞

#### AGT.1.2.11
* □□□
* デバイスのWeb UI で、アドミリンクメニューの「詳細設定」を選択する事で、「詳細設定画面」を開ける事。 <br> In the device's Web UI, select "Advanced" from the AdminLink menu to open the "Advanced Settings page".

### AGT.1.3
* 要求 <br> request
* 「基本設定画面」で、アドミリンク機能の有効/無効、デバイス登録状態確認、デバイスの登録/削除ができる事。 <br> また、アドミリンク機能が有効且つデバイスが登録済みの場合、ステータス更新とテストイベント通知ができる事。 <br> Enable/disable the AdminLink function, check the device registration status, and register/delete devices on the "Basic Settings" screen.  <br> In addition, when the AdminLink function is enabled and the device is already registered, enable status updates and test event notifications.

- 理由 | ・アドミリンク機能の有効/無効を切り替えたい <br> ・デバイス登録状態を確認したい <br> ・アドミリンクにデバイスを登録したい <br> ・アドミリンクに登録しているデバイスを削除したい <br> ・ステータス更新を行いたい <br> ・テストイベント通知を行いたい <br> Client wants to switch enable/disable the AdminLink function. <br> Client wants to check the device registration status. <br> Client wants to register the device to the AdminLink. <br> Client wants to delete the device registered to the AdminLink. <br> Client wants to update the status. <br> Client wants to send the test event.
- 説明
#### AGT.1.3.0
* ＜アドミリンク機能の有効/無効ステータス表示する＞ <br> ＜Display the enable/disable status of the AdminLink function.＞

#### AGT.1.3.1
* □□□
* 「基本設定画面」を開いた時点の、「アドミリンク機能」の有効/無効状態をWeb UIに表示する。 <br> Display the enable/disable status of the "AdminLink function" on the Web UI when the "Basic Settings" screen is open.

#### AGT.1.3.2
* □□□
* アドミリンク機能が「有効」の場合、デバイスの「登録状態」を表示する。 <br> アドミリンク機能が「無効」の場合は、「登録状態」項目名を含め、登録状態は表示しない。 <br> Display the "the device registration status" of the device when the AdminLink function is "enabled". <br> Do not display the device registration status, including the "registration status" item name, when the AdminLink function is "disabled".

#### AGT.1.3.10
* ＜アドミリンク機能の有効/無効を切り替える＞ <br> ＜Enable/Disable the AdminLink function.＞

#### AGT.1.3.11
* □□□
* 「基本設定画面」が開かれた時、アドミリンク機能の「有効/無効」設定を不揮発性メモリから読み出し、Web UI に反映する。 <br> The "Enable/Disable" setting of the AdminLink function is read from the non-volatile memory and reflected in the Web UI when the "Basic Settings" screen is open.

#### AGT.1.3.12
* □□□
* ・アドミリンク機能の有効/無効設定用「適用」ボタンがクリックされたら、UI上で選択されている有効/無効をWeb UIに反映する。 <br> ・設定を不揮発性メモリに保存する。 <br> ・The Web UI will reflect the enabled/disabled setting selected on the UI, when the "Apply" button for enabling/disabling the AdminLink function is clicked,  <br> ・Save settings to non-volatile memory.

#### AGT.1.3.13
* □□□
* アドミリンク機能が「有効」の場合は、＜アドミリンクサービスへの登録状態を表示する＞を実行する。 <br> If the AdminLink function is "enabled," execute <Display the registration status to the AdminLink service>.

#### AGT.1.3.14
* □□□
* アドミリンク機能が「無効」の場合は、アドミリンク機能の有効/無効選択と、適用ボタンの他、下記の各UIは非表示とする。 <br> When the AdminLink function is "disabled", the following UI will be hidden in addition to the AdminLink function enable/disable selection and the Apply button. <br> 　・登録状態の表示 <br> 　・Display of the registration status <br> 　・デバイス登録コード発行に関するUI <br> 　・UI for device registration code issuance <br> 　・手動操作に関するUI <br> 　・UI for manual operation <br> 　・登録情報/登録削除　に関するUI <br> 　・UI for registration information/deletion of registration

#### AGT.1.3.20
* ＜アドミリンクサービスへの登録状態を表示する＞ <br> ＜Display the registration status to the AdminLink service.＞

##### AGT.1.3.20.1
* □□□
* 画面のテキスト中のアドミリンクポータルサイトURL部はアドミリンクポータルサイト（https://admin-link.net）へのハイパーリンクにする。 <br> ハイパーリンクをクリックすると、ブラウザを別ウィンドウで開く。 <br> The URL on "アドミリンクポータルサイト（https://admin-link.net）" is a hyper-link. <br> Open a new browser window for the URL, when the hyper-link is clicked. <br>  <br> ※詳細については、デバイスのWeb UI仕様書を参照すること。 <br> 　------------- <br> 注意：アドミリンクサービス （https://admin-link.net） をご使用いただくためには、以下の条件を満たす必要があります。          <br> アドミリンク機能を「有効」にする前に、これらの条件を満たしていることをご確認ください。          <br> １．本製品がインターネットに接続できること          <br> ２．本製品の時刻設定にNTPサーバーを使用していること  <br> 　------------- <br>  <br> *Refer to the device's Web UI specifications for details. <br> 　------------- <br> Note: In order to use the AdminLink service (https://admin-link.net), the following conditions must be met. <br> Please make sure these conditions are met before you enable the AdminLink feature. <br> 1. This product must be able to connect to the Internet. <br> 2. This product must be set the correct time via NTP server. <br> 　-------------

#### AGT.1.3.21
* □□□
* デバイス内にデバイスIDが保存されている場合は、そのデバイスIDをデバイス登録確認（AGT 1.4）に使用する。 <br> When the device ID is held by the device, the device ID is used for device registration confirmation (AGT.1.4). <br>  <br> デバイス内にデバイスIDが保存されていない場合は、新規にデバイスIDを生成する。 <br> 生成したデバイスIDは、デバイス登録確認（AGT 1.4）のみに使用し、デバイス内に保存しない。 <br> When the device ID is not held by the device, generate a new device ID. <br> The generated device ID is used only for device registration confirmation (AGT.1.4), and will not be held by the device. <br>  <br> 「EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow)」の、 <br> 「2.Device entry startup flow」シートに従うこと。 <br> Follow the sheet 「2.Device entry startup flow」 on 「EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow)」 <br>  <br> 登録状態が「未登録」または「再登録可能」の場合は、「未登録」を表示する。 <br> If the registration status is "unregistered" or "re-registerable", "unregistered" is displayed. <br> 登録済みの場合は、「登録済み」を表示する。 <br> If the device has already been registered, "Registered" is displayed. <br> 登録状態を取得できない場合は、「確認中」を表示する。 <br> If the registration status cannot be obtained., "Checking" is displayed.

#### AGT.1.3.22
* □□□
* 登録状態が「未登録」または「再登録可能」の場合は、下記のUIを表示する。 <br> Display the following UI, If the registration status is "unregistered" or "re-registerable". <br> 　・「デバイス登録コード発行」に関するUI <br> 　・UI for "Device Registration Code Issuance" <br> 　・「登録情報」に関するUI <br> 　・UI for "Registration Information"

#### AGT.1.3.23
* □□□
* 登録状態が「登録済み」の場合は、下記のUIを表示する。 <br> Display the following UI if  the registration status is "Registered"　 <br> 　・「デバイス登録コード発行」に関するUI <br> 　・UI for "Device Registration Code Issuance' <br> 　・「手動操作」に関するUI <br> 　・UI for "Manual operation' <br> 　・「登録削除」に関するUI <br> 　・UI for "Registration deletion' <br> ただし、dev_id_changed = 1の場合（アドミリンクサービスへ登録後に、デバイスが出荷時リセットされた場合）は、「未登録」と判定し、「再登録」用のUIを表示する。 <br> However, display the UI for "re-registration" and  judge "unregistered", if dev_id_changed = 1 (when the device has been factory reset after registration to the AdminLink service).

#### AGT.1.3.24
* □□□
* 登録状態が「確認中」の場合は、下記のUIを表示する。 <br> Display the following UI if the registration status is "Checking." <br> 　・「デバイス登録コード発行」に関するUI <br> 　・UI for "Device Registration Code Issuance"

#### AGT.1.3.20B
* ＜デバイスの登録状態が「確認中」の場合＞ <br> When the registration status of the device is "Checking".

#### AGT.1.3.21B
* □□□
* デバイス登録状態が「確認中」の場合、「確認中」以外のステータスになるまでデバイス登録状態の確認をリトライする。 <br> リトライ間隔　60秒、リトライ回数　最大6回 <br> If the device registration status is "Checking", retry checking the device registration status until the status becomes something other than "Checking". <br> The interval 60 seconds, number of retris up to 6 times.

#### AGT.1.3.22B
* □□□
* 結果をログに記録する。「Log Message 」シートを参照。 <br> Log results. See the 'Log Message' sheet.

#### AGT.1.3.30
* ＜デバイス登録コードを発行する＞ <br> ＜Issue device registration code＞

#### AGT.1.3.31
* □□□
* UIの「デバイス登録コード」項目の値は初期状態を空白とし、デバイス登録コードが生成されるまでは何も表示しない。項目名は常時表示する。 <br> The value of the "Device Registration Code" item in the UI is initially set to blank and nothing is displayed until the device registration code is generated. The item name is always displayed.

#### AGT.1.3.32
* □□□
* 「デバイス登録コードの発行」ボタンがクリックされたら、デバイス登録コードを生成し、UIの「デバイス登録コード」に表示する。 <br> When the "Issue Device Registration Code" button is clicked, the device registration code is generated and displayed in the "Device Registration Code" section of the UI. <br> 既にデバイス登録コードが生成され、表示されている場合でも、「デバイス登録コードの発行」ボタンがクリックされたら生成し、表示を更新する。 <br> Even if the device registration code has already been generated and displayed, it will be generated and the display will be updated when the "Issue Device Registration Code" button is clicked.

#### AGT.1.3.33
* □□□
* デバイス登録コードは下記の計算方法で生成する。 <br> The device registration code shall be generated by the following calculation method. <br> ・16進数の9桁（文字列化する場合のアルファベットは大文字） <br> ・9 hexadecimal digits (uppercase letters are used for character strings) <br> ・1-4桁：デバイスのMACアドレスの下4桁 <br> ・1-4 digits: Last 4 digits of the device's MAC address <br> ・5-8桁：生成日時（日/時/分）で、16進数の4桁。空白は0で埋める（ゼロフィル）。 <br> ・5-8 digits: Generation date and time (day/hour/minute), 4 hexadecimal digits. Spaces are filled with zeroes (zero-fill). <br> 　例）2021年7月30日13時59分の場合 <br>   ex) At 13:59 on July 30, 2021 <br> 　　　30日→30×24時間×60分＝43200分 <br> 　　　30 days -> 30 x 24 hours x 60 minutes = 43200 minutes <br> 　　　13時→13×60分＝780分 <br>       13 hours -> 13 x 60 minutes = 780 minutes <br> 　　　59分＝59分 <br> 　　　59 minutes = 59 minutes <br> 　　　これらを合計すると10進数で44,039分、これを16進数に変換すると「AC07」となる。 <br> 　　　The total above is 44,039 decimal minutes, which is "AC07"when converted to hexadecimal. <br> ・9桁：1-8桁を足した値（16進数）の最下位1桁 <br> ・9 digit: Least significant digit of the value obtained by adding digits 1-8 (hexadecimal number) <br> 　例）1-8桁が E528AC07 の場合 <br> 　ex) If digits 1-8 are E528AC07 <br> 　E+5+2+8+A+C+0+7 = 3A <br> 　上記計算式より、'A' となる。 <br> 　From the above formula, it becomes'A'.

#### AGT.1.3.34
* □□□
* デバイス登録コードはReadOnlyで表示する。 <br> Display Device Registration Code by Read-Only or Write-protection.

#### AGT.1.3.35
* □□□
* 生成されたデバイス登録コードはデバイス側で保持しない。 <br> The device doesn't retain the value of the generated "Device Registration Code". <br>  <br> ブラウザが閉じる時や、WebUI の他の画面へ遷移する時、値を破棄する。 <br> Discard the value, when the browser is closed, or client moves to other screen of Web UI.

#### AGT.1.3.40
* ＜デバイス登録コードをクリップボードへコピーする＞ <br> ＜Copy the device registration code to the clipboard＞

#### AGT.1.3.41
* □□□
* デバイス登録コードの「コピー」ボタンがクリックされたら、表示されているデバイス登録コードをクリップボードへコピーする。デバイス登録コードが表示されていない場合は何もしない。 <br> When the "Copy" button for the device registration code is clicked, copy the device registration code displayed to the clipboard. If the device registration code is not displayed, do nothing.

#### AGT.1.3.50
* ＜デバイス初回登録用の「登録情報」に関するUIを表示する＞ <br> ＜Display the UI related to "Registration Information" for initial device registration.＞

#### AGT.1.3.51
* □□□
* 初回登録用のUI表示： <br> UI display for initial registration <br> 登録状態が「未登録」の場合の「登録情報」に関するUIは下記の表示とする。 <br> When the registration status is "Unregistered", the UI for "Registration Information" shall be displayed as follows. <br> 　「登録済みデバイス登録コード」入力ボックス：有効 <br> 　"Registered device registration code" input box: Enabled <br> 　「シリアル番号」入力ボックス：有効 <br> 　"Serial Number" input box: Enabled <br> 　「デバイス名」入力ボックス：有効 <br> 　"Device name" input box: Enabled <br> 　「備考」入力ボックス：有効 <br> 　"Remarks" input box: Enabled <br> 　「デバイス登録」ボタン：有効 <br> 　"Device Registration" button: Enabled

#### AGT.1.3.52
* □□□
* 各入力ボックスの初期値は下記とする。 <br> The initial values of each input box shall be as follows. <br> 　・登録済みデバイス登録コード：空白 <br> 　・Registered device registration code: blank <br> 　・シリアル番号：空白 <br> 　・Serial number: Blank <br> 　・デバイス名：アルファベット数文字 + MACアドレス（16進数数字のみ） <br> 　・Device name: Some alphabet characters + MAC address(Only hexidecimal digit) <br> 　・備考：空白 <br> 　・Remarks: Blank <br>  <br> デバイス名の詳細はWebUI仕様書を参照。 <br> Refer to the document "WebUI required specifications" for the detail of device name.

#### AGT.1.3.53
* □□□
* 初回登録では、下記を入力必須とする。 <br> The following information must be entered for the initial registration. <br> 　・登録済みデバイス登録コード <br> 　・Registered device registration code <br> 　・シリアル番号 <br> 　・Serial number <br> 　・デバイス名 <br> 　・Device name

#### AGT.1.3.54
* □□□
* 「デバイス登録」ボタンがクリックされたら、各入力ボックスに入力された値をチェックする。 <br> When the "Register Device" button is clicked, check the values entered in each input box. <br> ・必須項目が入力されていない場合は、エラーメッセージを表示する。 <br> ・If the required fields are not filled in, an error message will be displayed. <br> ・入力された値をチェックし、条件を満たしていない場合はエラーメッセージを表示する。 <br> ・Check the values entered, and if they do not meet the conditions, an error message is displayed. <br> ・必須項目、入力値、にエラーが無い場合は、入力された値でデバイスの登録処理を実行する。" <br> ・If there are no errors in the required fields or input values, the registration process of the device is executed with the input values. <br>  <br> 「UI Message」シートを参照。 <br> See the 'UI Message' sheet.

#### AGT.1.3.55
* □□□
* デバイス登録処理に成功した場合、デバイス登録状態を確認し、Web UIの表示を更新する。 <br> If the device registration process is successful, check the device registration status and update the Web UI display. <br> 実行結果をメッセージ表示する。 <br> Display the execution result as a message. <br>  <br> 「UI Message」シートを参照。 <br> See the 'UI Message' sheet.

#### AGT.1.3.56
* □□□
* ・デバイスの登録処理に成功した場合、アドミリンクサービス登録状態をデバイス登録済とする。 <br> ・If the device registration process is successful, make the registration status be "Registered". <br> ・定期処理を開始する。 <br> ・Start periodical process. <br> ・ステータスJSON、設定ステータスJSONデータをサーバーへ送信する。 <br> ・Send the status JSON data and the configuration status JSON data to the AdminLink server. <br>  <br>  <br> ステータスJSONデータの送信に関してはAGT.2.6を参照。 <br> About sending status JSON data, refer AGT.2.6. <br>  <br> 設定ステータスJSONデータの送信に関してはAGT.2.8.70を参照。 <br> About sending configuration status JSON data, refer AGT.2.8.70.

#### AGT.1.3.60
* ＜デバイスが再登録可能な場合の「登録情報」に関するUIを表示する＞ <br> ＜Show UI about "registration information" when the device can be re-registered＞

#### AGT.1.3.61
* □□□
* 再登録用のUI表示： <br> UI display for re-registration <br> 登録状態が「再登録可能」の場合の「登録情報」に関するUIは下記の表示とする。 <br> When the registration status is "re-registerable", the UI for "Registration information" shall be displayed as follows. <br> 　「登録済みデバイス登録コード」入力ボックス：有効 <br> 　"Registered device registration code" input box: Enabled <br> 　「シリアル番号」入力ボックス：無効 <br> 　"Serial Number" input box: Disabled <br> 　「デバイス名」入力ボックス：無効 <br> 　"Device name" input box: Disabled <br> 　「備考」入力ボックス：無効 <br> 　"Remarks" input box: Disabled <br> 　「デバイス再登録」ボタン：有効 <br> 　"Re-register Device" button: Enabled

#### AGT.1.3.62
* □□□
* 各入力ボックスの初期値は下記とする。 <br> The initial values of each input box shall be as follows. <br> 　・登録済みデバイス登録コード：空白 <br> 　・Registered device registration code: blank <br> 　・シリアル番号：空白 <br> 　・Serial number: Blank <br> 　・デバイス名：空白 <br> 　・Device name: Blank <br> 　・備考：空白 <br> 　・Remarks: Blank

#### AGT.1.3.63
* □□□
* 再登録では、下記を入力必須とする。 <br> For re-registration, the following must be entered. <br> 　・登録済みデバイス登録コード <br> 　・Registered device registration code

#### AGT.1.3.64
* □□□
* 「デバイス再登録」ボタンがクリックされたら、各入力ボックスに入力された値をチェックする。 <br> When the "Re-register Device" button is clicked, check the values entered in each input box. <br> ・必須項目が入力されていない場合は、エラーメッセージを表示する。 <br> ・If any of the required fields are not filled in, an error message will be displayed. <br> ・入力された値をチェックし、条件を満たしていない場合はエラーメッセージを表示する。 <br> ・Check the entered values, and if they do not meet the conditions, an error message will be displayed. <br> ・必須項目、入力値、にエラーが無い場合は、入力された値でデバイスの再登録処理を実行する。 <br> ・If there are no errors in the required fields or input values, the device is re-registered with the input values. <br>  <br> 「UI Message」シートを参照。 <br> See the 'UI Message' sheet.

#### AGT.1.3.65
* □□□
* デバイスの再登録処理に成功した場合、デバイス登録状態を確認し、Web UIの表示を更新する。 <br> If the device re-registration process is successful, the device registration status is checked and the Web UI display is updated. <br> 実行結果をメッセージ表示する。 <br> Display the execution result as a message. <br>  <br> 「UI Message」シートを参照。 <br> See the 'UI Message' sheet.

#### AGT.1.3.66
* □□□
* ・デバイスの再登録処理に成功した場合、アドミリンクサービス登録状態をデバイス登録済とする。 <br> ・If the device registration process is successful, make the registration status be "Registered". <br> ・定期処理を開始する。 <br> ・Start periodical process. <br> ・ステータスJSON、設定ステータスJSONデータをサーバーへ送信する。 <br> ・Send the status JSON data and the configuration status JSON data to the AdminLink server. <br>  <br>  <br> ステータスJSONデータの送信に関してはAGT.2.6を参照。 <br> About sending status JSON data, refer AGT.2.6. <br>  <br> 設定ステータスJSONデータの送信に関してはAGT.2.8.70を参照。 <br> About sending configuration status JSON data, refer AGT.2.8.70.

#### AGT.1.3.70
* ＜「手動操作」に関するUIを表示する＞ <br> ＜Display the UI for "Manual operation".＞

#### AGT.1.3.71
* □□□
* 「デバイス情報送信」ボタンを表示する <br> Display the "Send Device Information" button.

#### AGT.1.3.72
* □□□
* 「テストイベント発生」ボタンを表示する。 <br> Display the "Test Event Occurred" button.

#### AGT.1.3.73
* □□□
* 「デバイス情報送信」ボタンがクリックされた場合、「デバイス情報送信（手動によるステータス更新）」を実行する。 <br> When the "Send device information" button is clicked, "Send device information (manual status update)" is executed. <br> 実行結果をWeb UI上にメッセージ表示する。 <br> The execution result is displayed as a message on Web UI. <br>  <br> 「UI Message」シートを参照。 <br> See the 'UI Message' sheet.

#### AGT.1.3.74
* □□□
* 「テストイベント発生」ボタンがクリックされた場合、「テストイベントを送信」を実行する。 <br> When the "Test Event Occurred" button is clicked, "Send Test Event" is executed. <br> 実行結果をWeb UI上にメッセージ表示する。 <br> The execution result is displayed as a message on Web UI. <br>  <br> 「UI Message」シートを参照。 <br> See the 'UI Message' sheet.

#### AGT.1.3.80
* ＜「登録削除」に関するUIを表示する＞ <br> ＜Display the UI for "Delete Registration"＞

#### AGT.1.3.81
* □□□
* 「登録を削除する事に同意します」チェックボックスを表示する。 <br> Display the "I agree to delete my registration" checkbox. <br> デフォルトはOFF。 <br> Default is OFF.

#### AGT.1.3.82
* □□□
* 「デバイス登録削除」ボタンを表示する。 <br> Display the "Device unregister" button. <br> 「登録を削除することに同意します」チェックボックスがOFFの場合は無効（グレイアウト）、チェックボックスがONの場合は有効とする。 <br> If the "I agree to delete my registration" checkbox is OFF, the button is disabled (grayed out); if the checkbox is ON, the button is enabled.

#### AGT.1.3.83
* □□□
* 「デバイス登録削除」ボタンがクリックされた場合、デバイス登録解除を実行する。 <br> When the "Device unregister" button is clicked, perform the device unregister process. <br> デバイス登録削除に関しては「AGT.1.6」を参照。 <br> About device unregister, refer “AGT.1.6”. <br>  <br> 実行結果をメッセージ表示する。 <br> The execution result is displayed as a message. <br>  <br> 「UI Message」シートを参照。 <br> See the 'UI Message' sheet.

#### AGT.1.3.84
* □□□
* デバイス登録解除処理に成功した場合、デバイスの登録状態を確認し、Web UIの表示を更新する。 <br> If the device unregister process is successful, the device registration status is checked and the Web UI display is updated.

### AGT.1.4
* 要求 <br> request
* デバイス登録状態を確認できる事。 <br> Must be able to check the device registration status.

- 理由 | ・デバイス登録状態を確認したい <br> Client wants to check the device registration status.
- 説明 | 「デバイスID」とはデバイスが生成する識別情報で、Web APIをコールする際にパラメーターとして渡します <br> "Device ID" is the identification information generated by the device, which is passed as parameter when calling the Web API.
#### AGT.1.4.0
* ＜デバイス登録確認用 Web APIをコールする＞ <br> Call the Web API for device registration confirmation

#### AGT.1.4.1
* □□□
* [ Device registration confirmation API ] <br> デバイス内にデバイスIDが保存されている場合は、そのデバイスIDとMACアドレスを指定してデバイス登録確認用 Web API をコールする。 <br> When the device ID is held by the device, call the Web API for device registration confirmation specifying the device ID and MAC address. <br>  <br> デバイス内にデバイスIDが保存されていない場合は、新規にデバイスIDを生成し、そのデバイスIDとMACアドレスを指定してデバイス登録確認用 Web API をコールする。 <br> When the device ID is not held by the device, generate a new device ID, and call the Web API for device registration confirmation specifying the device ID and MAC address.

##### AGT.1.4.1.1
* □□□
* 本機にデバイスIDが保存されている場合、WebAPI（登録確認）の呼び出しを行う。 <br> 「EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow)」の、 <br> 「1.Device entry startup software flow」シートに従うこと。 <br> If the device ID is held by the device, call Web API (device registration confirmation). <br> Follow the sheet 「1.Device entry startup software flow」 on 「EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow)」.

##### AGT.1.4.1.2
* □□□
* 本機にデバイスIDが保存されていない場合、アドミリンクサービス登録状態を「未登録」とする。 <br> 「EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow)」の、 <br> 「1.Device entry startup flow」シートに従うこと <br> If the device ID is not held by the device, make the registration status to the AdminLink service be "Unregistered". <br> Follow the sheet 「1.Device entry startup flow」 on 「EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow)」.

##### AGT.1.4.1.3
* □□□
* 本機にデバイスIDが保存されていない場合、ログを出力する。 <br> If the device ID is not held by the device, log the message. <br> 「Log Message 」シートを参照。 <br> See the 'Log Message' sheet.

#### AGT.1.4.2
* □□□
* デバイスIDは、UUID Ver4 とする。 <br> The device ID shall be UUID Ver4.

#### AGT.1.4.3
* □□□
* 複数のMACアドレスを持つデバイスでは、スイッチの場合はシステムMACアドレス（Web UIのシステム画面上に表示されるもの）、APの場合はWAN側（Internet側）のMACアドレスとする。 <br> For a device with multiple MAC addresses, in the case of switch product, use system MAC address that is displayed on the "system" screen of Web UI to register the device. And in the case of access point product, use WAN MAC address (the one on Internet side) to register the device.

#### AGT.1.4.4
* □□□
* プロキシー設定が有効の場合、プロキシー経由でWeb APIをコールする。 <br> If the proxy setting is enabled, call the Web API through the proxy.

#### AGT.1.4.10
* ＜Web APIのレスポンスステータスが200且つdev_id_changed = 0の場合（登録済み）＞ <br> ＜If the Web API response status is 200 and dev_id_changed = 0 (already registered)＞

#### AGT.1.4.11
* □□□
* デバイス登録状態を「登録済み」と判定する。 <br> Determine the device registration status as "registered".

#### AGT.1.4.12
* □□□
* 結果をログに記録する。「Log Message 」シートを参照。 <br> Log results. See the 'Log Message' sheet.

#### AGT.1.4.13
* □□□
* RAM上に残っているJSONデータの送信リトライに6回連続で失敗しリトライが停止していた場合、送信リトライを再開する。(AGT.2.6.33参照） <br> If the device failed to send a unsent JSON data on RAM repeatedly 6 times and stop the retry, resume the retry. (Refer AGT.2.6.33)

#### AGT.1.4.20
* ＜Web APIのレスポンスステータスが200且つdev_id_changed = 1の場合（再登録可能）＞ <br> ＜If the Web API response status is 200 and dev_id_changed = 1 (can be re-registered)＞

#### AGT.1.4.21
* □□□
* デバイス登録状態を「再登録可能」と判定する。 <br> Determine the device registration status as "re-registrable".

#### AGT.1.4.22
* □□□
* デバイスは、Web APIからのレスポンスボディに含まれるデバイスID（dev_id キーの値）を保持する。（このデバイスIDは、デバイスの再登録時に使用する。） <br> The device retains the device ID (value of the dev_id key) included in the response body from the Web API. (This device ID will be used when the device is re-registered.)

#### AGT.1.4.23
* □□□
* 結果をログに記録する。「Log Message 」シートを参照。 <br> Log results. See the 'Log Message' sheet.

#### AGT.1.4.30
* ＜Web APIのレスポンスステータスが401の場合（未登録）＞ <br> ＜If the Web API response status is 401 (unregistered)＞

#### AGT.1.4.31
* □□□
* デバイス登録状態を「未登録」と判定する。 <br> Determine the device registration status as "unregistered".

#### AGT.1.4.32
* □□□
* デバイスIDを保持している場合、デバイスは保持しているデバイスIDを削除しなければならない。 <br> If the device retains a device ID, the device shall delete the device ID it holds.

#### AGT.1.4.33
* □□□
* 結果をログに記録する。「Log Message 」シートを参照。 <br> Log results. See the 'Log Message' sheet.

#### AGT.1.4.40
* ＜Web APIのレスポンスステータスが200または401以外の場合（エラー）＞ <br> ＜If the Web API response status is other than 200 or 401 (error)＞

#### AGT.1.4.41
* □□□
* デバイス登録状態を「確認中」とする。 <br> The device registration status shall be "Checking".

#### AGT.1.4.42
* □□□
* 結果をログに記録する。「Log Message 」シートを参照。 <br> Log results. See the 'Log Message' sheet.

#### AGT.1.4.50
* ＜Web APIをコールしたが、レスポンスステータスが得られなかった場合（エラー）＞ <br> ＜When the Web API is called, but no response status(error)＞

#### AGT.1.4.51
* □□□
* 登録状態を「確認中」とする。 <br> The status of the device status shall be "Checking".

#### AGT.1.4.52
* □□□
* 結果をログに記録する。「Log Message 」シートを参照。 <br> Log results. See the 'Log Message' sheet.

### AGT.1.5
* 要求 <br> request
* デバイスをアドミリンクサービスへ登録できる事。 <br> The device must be able to register with the AdminLink service.

- 理由 | ・アドミリンクサービスにデバイスを登録したい <br> Client wants to register the device to the AdminLink service.
- 説明
#### AGT.1.5.0
* ＜デバイス登録用Web APIをコールする＞ <br> ＜Call the Web API for device registration＞

#### AGT.1.5.1
* □□□
* 初回登録時はデバイスIDを新規に生成して指定する。 <br> When registering for the first time, generate a new device ID and specify it. <br> 再登録時は、登録確認用Web APIのレスポンスボディに含まれるデバイスID(dev_idキーの値)を指定する。 <br> When re-registering, specify the device ID (dev_id key value) included in the Web API response body for registration confirmation. <br>  <br> Web APIのパラメータに関しては「EJ03.(AdminLink) 01_ WebAPI Specifications」の「2.2.Device registration API」シートを参照。 <br> For the detail about re-registration paremeters, see "Input data" on the sheet 「2.2.Device registration API」 of 「EJ03.(AdminLink) 01_ WebAPI Specifications」.

##### AGT.1.5.1.1
* □□□
* 複数のMACアドレスを持つデバイスでは、 <br> 　スイッチの場合：システムMACアドレス、 <br> 　APの場合：WANのMACアドレスとする。 <br> For a device with multiple MAC addresses, <br> In the case of switch product, use the system MAC address to call the Web API, <br> In the case of access point product, use WAN MAC address to call the Web API. <br>  <br> 【注】通信中のLANポートのMACアドレスではない。AGT.1.4.3を参照。 <br> Note: Not the MAC address of the LAN port on communication. Reffer "AGT.1.4.3".

#### AGT.1.5.2
* □□□
* APIコール時のパラメーターは別紙「AdminLink_DeviceRegistrationAPI_Parameters(APSW)」を参照。 <br> Refer to the Appendix "AdminLink_DeviceRegistrationAPI_Parameters(APSW)" for the parameters when making API calls.

#### AGT.1.5.3
* □□□
* プロキシー設定が有効の場合、プロキシー経由でWeb APIをコールする。 <br> If the proxy setting is enabled, call the Web API through the proxy.

#### AGT.1.5.10
* ＜Web APIのレスポンスステータスが 201 （登録成功）の場合＞ <br> ＜If the Web API response status is 201 (registration succeeded)＞

#### AGT.1.5.11
* □□□
* 登録したデバイスIDをデバイスに保持する。 <br> Retain the registered device ID in the device. <br>  <br> ・WebAPI（デバイス登録）の戻り値が201で、WebAPI応答のデバイスID変更フラグが立っていた場合、受け取ったデバイスIDで本機保持中のデバイスIDを上書きする。 <br> If the return value of Web API (Device registration) is '201', and the value of device ID change flag is '1', overwrite the device ID retained on the device by the one returned from the AdminLink server. <br> ・WebAPI（デバイス登録）の戻り値が201で、WebAPI応答のデバイスID変更フラグが立っていなかった場合、APIに指定したデバイスIDで本機保持中のデバイスIDを上書きする。 <br> If the return value of Web API (Device registration) is '201', and the value of device ID change flag is '0', overwrite the device ID held on the device by the one specifed for the Web API calling. <br>  <br> EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow)の「3.Device registration flow」シートの通りに実装されている事。 <br> Follow the sheet 「3.Device registration flow」 on 「EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow)」.

#### AGT.1.5.12
* □□□
* 結果をログに記録する。「Log Message 」シートを参照。 <br> Log results. See the 'Log Message' sheet.

##### AGT.1.5.12.1
* □□□
* WebAPI（デバイス登録）の戻り値が201の場合、受け取ったエージェント日次処理実行時刻計算用秒数(agt_daily_sec)を本体保持し、以降の日次処理開始タイミングに適用する。 <br> If the return value of Web API (Device registration) is '201', receive the value of "number of seconds for calculating the agent daily processing execution time"(agt_daily_sec), and retain it on the device for the beginning of daily process.

##### AGT.1.5.12.2
* □□□
* WebAPI（デバイス登録）の戻り値が201の場合、受け取ったエージェントステータス情報送信実行計算用秒数(agt_upload_sec)を本体保持し、以降のステータス情報通知タイミングへ適用する。 <br> If the return value of Web API (Device registration) is '201', receive the value of "Number of seconds for calculating agent information transmission timing"(agt_upload_sec), and retain it on the device for the sending the device status information to Admin Link server.

##### AGT.1.5.12.3
* □□□
* デバイス登録が成功した時、未送信の古いJSONデータがRAMに残っている場合は、それらを削除する。 <br> When the device registration process is successful, if there is a unsent old JSON data on RAM, delete it.

##### AGT.1.5.12.4
* □□□
* 未送信の古いJSONデータの削除に失敗した場合、ログを出力する。「Log Message 」シートを参照。 <br> When unsent old JSON data deletion process is failed, log result. See the 'Log Message' sheet. <br> アドミリンクエージェント機能を停止する。 <br> Then stop the AdminLink agent function.

#### AGT.1.5.13
* □□□
* 下記のイベントJSONをアドミリンクサーバーへ送信する。 <br> Send the following event JSON to the AdminLink server. <br> アクションID（5060）エージェント初期化 <br> Action ID (5060) Agent initialization

#### AGT.1.5.20
* ＜Web APIのレスポンスステータスが 201 以外の場合（エラー）＞ <br> ＜If the Web API response status is other than 201 (error)＞

#### AGT.1.5.21
* □□□
* Web APIのレスポンスボディを参照し、エラーメッセージを表示する。 <br> Refer to the Web API response body and display error messages on Web UI. <br>  <br> エラーメッセージには、デバイス登録 Web API のレスポンスボディに含まれるエラーID(error_idキーの値)とエラーメッセージ(error_msgキーの値)、エラー項目ID（error_fieldの値）、エラー項目値（error_valueの値）を用いる。 <br> To create the error message, use "error ID"(error_id key value), "error message"(error_msg key value) , "Error item ID"(error_field key value) and "Error item value"(error_value key value) included in the Web API response body for Device registration. <br>  <br> 詳細は 「EJ03.(AdminLink) 01_ WebAPI Specifications」.の「2.2.Device registration API」シートにある「About error ID and error message」を参照。 <br> For the detail, see 「About error ID and error message」 on the sheet 「2.2.Device registration API」 of 「EJ03.(AdminLink) 01_ WebAPI Specifications」. <br>  <br> 「UI Message」シートを参照。 <br> See the 'UI Message' sheet.

#### AGT.1.5.22
* □□□
* 結果をログに記録する。「Log Message 」シートを参照。 <br> Log results. See the 'Log Message' sheet.

#### AGT.1.5.30
* ＜Web APIをコールしたが、レスポンスステータスが得られなかった場合（エラー）＞ <br> ＜When the Web API is called, but no response status(error)＞

#### AGT.1.5.31
* □□□
* エラーメッセージを表示する。 <br> Display an error message. <br>  <br> 「UI Message」シートを参照。 <br> See the 'UI Message' sheet.

#### AGT.1.5.32
* □□□
* 結果をログに記録する。「Log Message 」シートを参照。 <br> Log results. See the 'Log Message' sheet.

### AGT.1.6
* 要求 <br> request
* アドミリンクサービスからデバイスの登録を削除できる事 <br> Must be able to remove the device registration from the AdminLink service

- 理由 | ・アドミリンクサービスからデバイス登録を削除したい <br> Client wants to remove the device registration from the AdminLink service.
- 説明
#### AGT.1.6.0
* ＜デバイス登録削除用Web APIをコールする＞ <br> ＜Call the Web API for device registration deletion＞

#### AGT.1.6.1
* □□□
* デバイスIDを指定してコールする。 <br> Specify and call the device ID.

#### AGT.1.6.2
* □□□
* プロキシー設定が有効の場合、プロキシー経由でWeb APIをコールする。 <br> If the proxy setting is enabled, call the Web API through the proxy.

#### AGT.1.6.10
* ＜Web APIのレスポンスステータスが 200 （登録削除成功）の場合＞ <br> ＜If the Web API response status is 200 (registration deletion succeeded)＞

#### AGT.1.6.11
* □□□
* 結果をログに記録する。「Log Message 」シートを参照。 <br> Log results. See the 'Log Message' sheet.

##### AGT.1.6.11.1
* □□□
* デバイスの登録削除が成功した後、実行中のエージェントをデバイス登録前の状態にするため下記処理を実施する。 <br> After the registration deletion is successful, perform the following processes to make active AdminLink agent be back to the initial state before the device registration. <br>  <br> ・ステータスを「デバイス登録済」から「未登録」へ変更 <br> Change the device registration status from 'Registered' to 'Unregistered'  <br> ・定期処理を実行している場合は停止する。 <br> Stop the periodical process if it is being performed. <br> ・遠隔操作を受け付けている場合は停止する。 <br> Stops if remote control is being accepted. <br> ・未送信のJSONデータをすべて削除する。  <br> Delete all unsent JSON datas. <br> ・ステータスやイベント用テンポラリファイルのクリア <br> Reset all agent inside status, and clear all temporary files.

#### AGT.1.6.20
* ＜Web APIのレスポンスステータスが 200 以外の場合（エラー）＞ <br> ＜If the Web API response status is other than 200 (error)＞

#### AGT.1.6.21
* □□□
* Web APIのレスポンスボディを参照し、エラーメッセージを表示する。 <br> Refer to the Web API response body and display error messages. <br>  <br> エラーメッセージには、デバイス登録解除 Web APIのレスポンスボディに含まれるエラーID(error_idキーの値)とエラーメッセージ(error_msgキーの値)、エラー項目ID（error_fieldの値）、エラー項目値（error_valueの値）を用いる。 <br> To create the error message, use "error ID"(error_id key value), "error message"(error_msg key value) , "Error item ID"(error_field key value) and "Error item value"(error_value key value) included in the Web API response body for Device deregistration. <br>  <br> 詳細は 「EJ03.(AdminLink) 01_ WebAPI Specifications」.の「2.10.Device deregistration API」シートにある「About error ID and error message」を参照。 <br> For the detail, see 「About error ID and error message」 on the sheet 「2.10.Device deregistration API」 of 「EJ03.(AdminLink) 01_ WebAPI Specifications」. <br>  <br>  <br> 「UI Message」シートを参照。 <br> See the 'UI Message' sheet.

#### AGT.1.6.22
* □□□
* 結果をログに記録する。「Log Message 」シートを参照。 <br> Log results. See the 'Log Message' sheet.

#### AGT.1.6.23
* □□□
* エラーIDが4012（デバイス情報が登録されていない）の場合、AGT.1.6.11.1と同じことを行う。 <br> When the Web API returns error ID 4012(Device information is not registered), do the same process as AGT.1.6.11.1.

#### AGT.1.6.30
* ＜Web APIをコールしたが、レスポンスステータスが得られなかった場合（エラー）＞ <br> ＜When the Web API is called, but no response status(error)＞

#### AGT.1.6.31
* □□□
* エラーメッセージを表示する。 <br> Display an error message. <br>  <br> 「UI Message」シートを参照。 <br> See the 'UI Message' sheet.

#### AGT.1.6.32
* □□□
* 結果をログに記録する。「Log Message 」シートを参照。 <br> Log results. See the 'Log Message' sheet.

### AGT.1.7
* 要求 <br> request
* アドミリンクサービスへデバイスを再登録できる事 <br> Must be able to re-register the device with the AdminLink service

- 理由 | ・アドミリンクサービスにデバイスを再登録したい <br> Client wants to re-register the device to the AdminLink service.
- 説明
#### AGT.1.7.0
* ＜デバイス登録処理を「再登録」として実行する＞ <br> ＜Execute the device registration process as "re-registration"＞

#### AGT.1.7.1
* □□□
* 登録確認用Web APIのレスポンスボディに含まれるデバイスID(dev_idキーの値)を指定して、デバイス登録用Web APIをコールする。以降の処理は、初回登録処理(AGT.1.5)と同じ。 <br> Specify the device ID (dev_id key value) included in the response body of the Web API for registration confirmation, and call the Web API for device registration. The rest of the process is the same as the initial registration process (AGT.1.5). <br>  <br> Web APIのパラメータに関しては「EJ03.(AdminLink) 01_ WebAPI Specifications」の「2.2.Device registration API」シートを参照。 <br> For the detail about re-registration paremeters, see "Input data" on the sheet 「2.2.Device registration API」 of 「EJ03.(AdminLink) 01_ WebAPI Specifications」.

### AGT.1.8
* 要求 <br> request
* デバイス情報送信（手動によるステータス更新）ができる事 <br> Must be able to send device information (manual status update)

- 理由 | ・ステータス更新を行いたい <br> Client wants to update the device status.
- 説明
#### AGT.1.8.0
* ＜デバイスのステータス情報を更新してアドミリンクサーバーへ送信する＞ <br> ＜Update the device status information and send it to the AdminLink server＞

#### AGT.1.8.1
* □□□
* 「ステータスJSON」および「設定ステータスJSON」データを更新してアドミリンクサーバーへ送信する。 <br> Update the status JSON data and configuration status JSON data and send them to the AdminLink server.

#### AGT.1.8.2
* □□□
* ステータスJSONデータ内のステータスタイプを「任意通知」（sts_type = 2）とする。 <br> Set the status type in the status JSON data to "Optional Notification" (sts_type = 2).

#### AGT.1.8.3
* □□□
* ステータスJSONデータの送信に関してはAGT.2.6を参照。 <br> About sending status JSON data, refer AGT.2.6. <br> ただし、手動によるステータス更新の場合は、JSONデータの送信に失敗してもリトライ処理を実施せず、Web UIでエラーメッセージを表示すること。 <br> However, in the case of manual status updates, if the JSON data fails to be sent, no retry processing should be performed and error messages should be displayed in the Web UI.

#### AGT.1.8.4
* □□□
* 設定ステータスJSONデータの送信に関してはAGT.2.8.70を参照。 <br> About sending configuration status JSON data, refer AGT.2.8.70.

### AGT.1.9
* 要求 <br> request
* テストイベントを送信できる事 <br> Must be able to send test events

- 理由 | ・テストイベント通知を行いたい <br> Client wants to send a test event.
- 説明
#### AGT.1.9.0
* ＜テストイベントJSONをアドミリンクサーバーへ送信する＞ <br> ＜Send the test event JSON to the AdminLInk server＞

#### AGT.1.9.1
* □□□
* テストイベントJSONデータを作成し、アドミリンクサーバーへ送信する <br> Create test event JSON data and send it to the AdminLink server

#### AGT.1.9.2
* □□□
* テストイベントJSONデータの送信に関してはAGT.2.6を参照。 <br> See AGT.2.6 for information on sending test event JSON data. <br>  <br> ただし、テストイベントJSONデータの送信に失敗してもリトライ処理を実施せず、Web UIでエラーメッセージを表示すること。 <br> However, if the test event JSON data fails to be sent, no retry processing should be performed and an error message should be displayed in the Web UI.

### AGT.1.10
* 要求 <br> request
* 「詳細設定画面」でアドミリンクサーバー接続用のプロキシー設定と、遠隔操作に関する設定について現在値の参照と設定変更をできる事。 <br> Must be able to refer to the current values and change the settings of the proxy settings for connecting to the AdminLink server and the remote control settings on the "Advanced Settings" screen.

- 理由 | ・アドミリンクサーバーへのアクセスにプロキシーを使用したい <br> ・遠隔操作の設定を変更したい <br> Client wants to use the proxy for access to the AdminLink server. <br> Client wants to change the remote control settings.
- 説明
#### AGT.1.10.0
* ＜プロキシーサーバー設定の現在値を参照する＞ <br> ＜Refer to the current value of the proxy server settings.＞

#### AGT.1.10.1
* □□□
* 下記のコントロールをWeb UIに表示し、プロキシーサーバー設定の現在値を反映する。 <br> Display the following controls in the Web UI to reflect the current value of the proxy server setting. <br> 　・プロキシーサーバー：ラジオボタン（使用する/使用しない） <br> 　・Proxy server: radio button (use/not use) <br> 　　デフォルトは「使用しない」 <br> 　　Default is "Do not use". <br> 　・アドレス：テキスト入力ボックス <br> 　・Address: Text input box <br> 　・ポート：テキスト入力ボックス <br> 　・Port: text input box <br> 　・ユーザー名：テキストボックス <br> 　・User name: text box <br> 　・パスワード：テキストボックス（入力データは伏字とする） <br> 　・Password: text box (The input data shall be hidden.)

#### AGT.1.10.2
* □□□
* プロキシーサーバーの設定が「使用しない」の場合、下記のコントロールは無効化する。 <br> If the proxy server setting is "Do not use", the following controls are disabled. <br> 　・アドレス：テキスト入力ボックス <br> 　・Address: text input box <br> 　・ポート：テキスト入力ボックス <br> 　・Port: text input box <br> 　・ユーザー名：テキストボックス <br> 　・User name: text box <br> 　・パスワード：テキストボックス <br> 　・Password: text box

#### AGT.1.10.10
* ＜遠隔操作に関する設定の現在値を参照する＞ <br> ＜Refer to the current value of the settings related to remote control.＞

#### AGT.1.10.11
* □□□
* 下記のコントロールをWeb UIに表示し、遠隔操作に関する設定の現在値を反映する。 <br> The following controls are displayed in the Web UI to reflect the current values of the settings related to remote control. <br> ・遠隔操作許可：ラジオボタン（有効/無効） <br> ・Remote control permission: radio button (enable/disable) <br> 　デフォルトは無効とする。 <br> 　The default setting is disabled. <br> ・設定ファイルアップロード許可：ラジオボタン（有効/無効） <br> ・Configuration file upload permission: radio button (enable/disable) <br> 　デフォルトは無効とする。 <br> 　The default is disabled. <br> ・ログファイルアップロード許可：ラジオボタン（有効/無効） <br> ・Log file upload permission: radio button (enable/disable) <br> 　デフォルトは無効とする。 <br> 　The default is disabled. <br> ・接続クライアントファイルアップロード許可（有効/無効） <br> ・Connected client file upload permission (enable/disable) <br> 　デフォルトは無効とする。 <br> 　The default is disabled. <br> ・接続クライアントファイル自動アップロード間隔：ドロップダウンリスト（なし/1時間/3時間/6時間） <br> ・Automatic upload interval of connection client file: Dropdown list (None / 1 hour / 3 hours / 6 hours) <br> 　デフォルトは6時間とする。 <br> 　Default is 6 hours.

#### AGT.1.10.12
* □□□
* 「遠隔操作許可」で無効が選択された場合、下記のコントロールは無効化する。 <br> When "Disable" is selected for "Remote control permission", the following controls is disabled. <br> ・設定ファイルアップロード許可：ラジオボタン（有効/無効） <br> ・Configuration file upload permission: radio button (enable/disable) <br> ・ログファイルアップロード許可：ラジオボタン（有効/無効） <br> ・Log file upload permission: radio button (enable/disable) <br> ・接続クライアントファイルアップロード許可（有効/無効） <br> ・Allow connection client file upload (enable/disable) <br> ・接続クライアントファイル自動アップロード間隔：ドロップダウンリスト（なし/1時間/3時間/6時間） <br> ・Automatic upload interval of connection client file: Dropdown list (None / 1 hour / 3 hours / 6 hours) <br> 「遠隔操作許可」で有効が選択された場合は、コントロールを有効化する。 <br> If Enable is selected for "Remote Control Permission", the Control is enabled.

#### AGT.1.10.13
* □□□
* 「接続クライアントファイルアップロード許可」で「無効が選択された場合、下記のコントロールは無効化する。 <br> If "Disabled" is selected for "Allow connection client file upload", the following controls are disabled. <br> ・接続クライアントファイル自動アップロード間隔：ドロップダウンリスト（なし/1時間/3時間/6時間） <br> ・Automatic upload interval for client files: Dropdown ｌist (None / 1 hour / 3 hours / 6 hours) <br> 「接続クライアントファイルアップロード許可」で有効が選択された場合は、コントロールを有効化する。 <br> If "Enable" is selected for "Allow connection client file upload", the control is enabled.

#### AGT.1.10.20
* ＜プロキシーサーバーの設定と遠隔操作に関する設定をデバイスへ反映する＞ <br> ＜Reflect the proxy server settings and remote control settings on the device.＞

#### AGT.1.10.21
* □□□
* ・「適用」ボタンがクリックされたら、各入力ボックスに入力された値をチェックする。 <br> ・When the "Apply" button is clicked, the values entered in each input box are checked. <br> ・必須項目が入力されていない場合は、エラーメッセージを表示する。 <br> ・When the "Apply" button is clicked, check the values entered in each input box. <br> ・入力された値をチェックし、条件を満たしていない場合はエラーメッセージを表示する。 <br> ・Check the entered values, and display an error message if the condition is not satisfied. <br> ・必須項目、入力値、にエラーが無い場合は、入力された値をプロキシーサーバーの設定と遠隔操作に関する設定をデバイスに反映し、保持する。 <br> ・If there are no errors in the required fields or entered values, the entered values are reflected in the device with the proxy server settings and remote control settings, and retain them. <br>  <br> 「UI Message」シートを参照。 <br> See the 'UI Message' sheet.

#### AGT.1.10.22
* □□□
* アドミリンクエージェントへ入力値を適用時、ログを出力する。 <br> When the entered values are reflected into the AdminLink agent, log the message. <br>  <br> 「Log Message 」シートを参照。 <br> See the 'Log Message' sheet.

#### AGT.1.10.23
* □□□
* 設定変更の「適用」ボタンがクリックされた時、各入力ボックスの値に変更が無ければ適用処理を実行しない。 <br> When "apply" button is clicked, If there is no change on each input-text-box, don't perform the configuration update process. <br> ログも出力しない。 <br> No log.

#### AGT.1.10.30
* ＜遠隔操作に関する設定をアドミリンクサーバー側と同期する＞ <br> ＜Synchronize remote control settings with AdminLink server side.＞

#### AGT.1.10.31
* □□□
* 遠隔操作に関する設定がデバイスに反映され、保持されたら、ステータスJSONデータを更新してアドミリンクサーバーへ送信する。 <br> Once the remote control settings are reflected into the device and retained, update the status JSON data and send it to the AdminLink server. <br> ※遠隔操作に関する設定をアドミリンクサーバー側と同期するため。 <br> ※This is to synchronize the remote control settings with the AdminLink server side.

#### AGT.1.10.40
* ＜プロキシーサーバーの設定と遠隔操作に関する設定をキャンセルする＞ <br> ＜Cancel the proxy server settings and remote control settings.＞

#### AGT.1.10.41
* □□□
* [キャンセル]ボタンをクリックすると、本画面の入力ボックスの項目のみ変更前の値へ戻す。 <br> When "Cancel' button is clicked, change all values in each input box back to ones before editing. <br>  <br> 【注】画面上の値を変えるだけで、適用までは行わない。 <br> Note: Don't apply all values in each input box, Just change all of them back to ones before editing. <br>  <br> ※例外として、Web UI上にある[適用]ボタンを持つ他の画面において[キャンセル]ボタンがない場合、画面のデザインをWeb UI全体で統一する意味で[キャンセル]ボタンを実装しない。 <br> ※As exception, in the case that there is no screen with "Apply" button but without "Cancel" button on Web UI, to unify whole UI, don't implement "Cancel" button.

#### AGT.1.10.42
* □□□
* ブラウザが閉じる時や、WebUI の他の画面へ遷移する時、入力内容を破棄する。 <br> Discard the editing, when the browser is closed, or client moves to other screen of Web UI.

### AGT.1.11
* 要求 <br> request
* 設定ファイルを用いて設定を復元した場合、アドミリンクに関連する設定値を全てクリアする事。 <br> Must clear all Adminlink related values when restoring device configuration by a configuration file.

- 理由 | アドミリンクに関連する設定値は各デバイス毎に特有の値とし、他のデバイスと重複しない。 <br> Adminlink related values are all unique for each device. Don't repeat with ones that other device has.
- 説明
#### AGT.1.11.0
* ＜設定ファイルを用いた設定復元＞ <br> ＜Restoring device configuration by a configuration file.＞

#### AGT.1.11.1
* □□□
* 設定ファイルを用いてデバイスの設定値を復元する際、デバイスが持つ "Device ID", "agt_upload_sec", "agt_daily_sec" の値をクリアする。 <br> When restoring device configuration by a configuration file, clear the value of "Device ID", "agt_upload_sec", "agt_daily_sec" on the device side.

## AGT.2
* 要求 <br> request
* アドミリンク機能が有効且つ登録済みの間、エージェントは機能し続け、イベントの監視と定期的な処理を実行できる事。 <br> As long as the AdminLink function is enabled and registered, the agent should continue to function and it must be able to monitor events and perform periodically process.

- 理由 | ・イベント監視を行いたい <br> ・定期的な処理を実行したい <br> Client wants to monitor events. <br> Client wants to process periodically.
- 説明
### AGT.2.1
* 要求 <br> request
* アドミリンクエージェント機能を開始できる事 <br> Must be able to start the AdminLink agent function

- 理由 | ・アドミリンクエージェント機能を開始したい <br> Client wants to start the AdminLink agent function.
- 説明
#### AGT.2.1.0
* ＜デバイス起動時にエージェント機能を開始する＞ <br> ＜Start the agent function at the device startup＞

#### AGT.2.1.1
* □□□
* デバイス起動時、アドミリンク機能が「有効」の場合、エージェント機能を開始する。 <br> The agent function willl start if the AdminLink function is "enabled"at the device startup. <br> アドミリンク機能が「無効」の場合、エージェント機能は開始しない。 <br> The agent function will not start, if the AdminLink function is "disabled."

#### AGT.2.1.2
* □□□
* エージェント機能を開始した場合、ログを記録する。 <br> Log if the agent function starts.

#### AGT.2.1.10
* ＜アドミリンク機能が無効から有効に変更された時、エージェント機能を開始する＞ <br> ＜Start the agent function when the AdminLink function is changed from disabled to enabled.＞

#### AGT.2.1.11
* □□□
* Web UI の操作により、アドミリンク機能が無効から有効に変化した場合、エージェント機能を開始する。 <br> The agent function will start if the AdminLink function changes from disabled to enabled by the Web UI's operation.

#### AGT.2.1.12
* □□□
* エージェント機能を開始した場合、ログを記録する。「Log Message 」シートを参照。 <br> Log if the agent function starts.See the 'Log Message' sheet.

#### AGT.2.1.13
* □□□
* 設定ファイルにデバイスのMACアドレスを保持している場合、エージェント開始時に設定ファイルが存在しており、設定ファイルのMACアドレスと実機のMACアドレスが異なる場合、アドミリンク機能を有効にした時には未登録扱いとなるようにする。 <br> If the configuration file includes device's MAC address information, <br> When AdminLink agent starts with configuration file, and the MAC address on configuration file is different from one on the device, the device registration status shall be 'Unregistered'　when the AdminLink function is changed to "enabled". <br>  <br> 【注】エージェント開始時にアドミリンクの登録情報を削除する。 <br> Note: This case, delete the device registration information on AdminLink server.

#### AGT.2.1.14
* □□□
* 設定ファイルにデバイスのMACアドレスを保持している場合、エージェント開始時に設定ファイルが存在しており、設定ファイルのMACアドレスと実機のMACアドレスが異なる場合、ログを出力する。 <br> If the configuration file includes device's MAC address information, <br> When AdminLink agent starts with configuration file, and the MAC address on configuration file is different from one on the device, log the message. <br> 「Log Message 」シートを参照。 <br> See the 'Log Message' sheet.

#### AGT.2.1.15
* □□□
* エージェント機能が誤動作しないように、エージェントが使用する変数や作業領域などを初期化する事。 <br> To prevent AdminLink function from the malfunction, initialize the variables and work space  that the agent uses, <br>  <br> 「EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow)」の「1.Device entry_software flow」シートの通りに実装されている事。 <br> Follow the sheet 「1.Device entry_software flow」 on 「EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow)」.

#### AGT.2.1.20
* ＜エージェント機能開始時にデバイス登録状態を確認する＞ <br> ＜Check the device registration status when the agent function starts.＞

#### AGT.2.1.21
* □□□
* AGT.1.4の処理を実行して、デバイス登録状態を確認する <br> Check the device registration status by the process of AGT.1.4. <br>  <br> 「EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow)」の、 <br> 「1.Device entry_software flow」シートに従うこと。 <br> Follow the sheet 「1.Device entry_software flow」 on 「EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow)」

#### AGT.2.1.30
* ＜デバイスの登録状態が「確認中」の場合＞ <br> When the registration status of the device is "Checking".

#### AGT.2.1.31
* □□□
* デバイス登録状態が「確認中」の場合、最大6回、「確認中」以外のステータスになるまでデバイス登録状態の確認をリトライする。 <br> If the device registration status is "Checking", up to 6 times, retry checking the device registration status until the status becomes something other than "Checking".

#### AGT.2.1.40
* ＜デバイスの登録状態が「登録済み」の場合＞ <br> ＜When the device registration status is "Registered".＞

#### AGT.2.1.41
* □□□
* 定期処理を開始する。 <br> Start periodical process. <br> 遠隔操作の受付を開始する。 <br> Start remote control reception.

#### AGT.2.1.50
* ＜デバイスの登録状態が「未登録」の場合＞ <br> ＜When the registration status of the device is "Unregistered".＞

#### AGT.2.1.51
* □□□
* アドミリンクサービスに未登録の場合、定期処理を実行している場合は停止する。 <br> If the device is unregisterd to the AdminLink service, stop if periodical process is being performed. <br> 遠隔操作を受け付けている場合は停止する。 <br> Stops if remote control is being accepted.

#### AGT.2.1.52
* □□□
* エージェント機能の停止をログに記録する。「Log Message 」シートを参照。 <br> Log the stop of an agent function. See the 'Log Message' sheet.

### AGT.2.2
* 要求 <br> request
* アドミリンクエージェント機能を停止できる事 <br> Must be able to stop the AdminLink agent function

- 理由 | ・アドミリンクエージェント機能を停止したい <br> Client wants to stop the AdminLink agent function.
- 説明
#### AGT.2.2.0
* ＜アドミリンク機能が有効から無効に変更された時、エージェント機能を停止する＞ <br> Stop the agent function when the AdminLink function is changed from enabled to disabled.

#### AGT.2.2.1
* □□□
* Web UI の操作により、アドミリンク機能が有効から無効に変化した場合、エージェント機能を停止する。 <br> When the AdminLink function changes from enabled to disabled by Web UI operation, the agent function will stop.

#### AGT.2.2.2
* □□□
* エージェント機能を停止した場合、ログに記録する。「Log Message 」シートを参照。 <br> Log  when the agent function stops.See the 'Log Message' sheet.

### AGT.2.3
* 要求 <br> request
* 日次処理（24時間毎）を実施できる事 <br> Must be able to carry out daily processing (every 24 hours)

- 理由 | 日次処理を実行したい <br> ・Client wants to process dairy.
- 説明
#### AGT.2.3.0
* ＜日次処理の開始＞ <br> ＜Start daily processing＞

#### AGT.2.3.1
* □□□
* アドミリンク機能が有効且つ、デバイス登録状態が「登録済み」または「確認中」の場合、24時間に一度、日次処理を実行する。 <br> When the AdminLink function is enabled and the device registration status is "Registered" or "Checking", the daily processing is executed once every 24 hours. <br>  <br> 「エージェント日次処理実行時刻計算用秒数」（デバイス登録Web APIのレスポンスボディに含まれる「agt_daily_sec」キーの値）を取得していない場合には、日次処理を実行しない。 <br> When the device does not have the value of The "number of seconds for calculating the agent daily processing execution time" (the value of key "agt_daily_sec" in the response body of device registration Web API), don't execute daily processing

#### AGT.2.3.2
* □□□
* 日次処理は、22:00:00を起点とし、「エージェント日次処理実行時刻計算用秒数」を加算した時刻に開始する。「エージェント日次処理実行時刻計算用秒数」は、デバイス登録Web APIのレスポンスボディに含まれる「agt_daily_sec」キーの値である（この値は秒数）。 <br> Daily processing starts at 22:00:00, and at the time added by the "number of seconds for calculating the agent daily processing execution time". The "number of seconds for calculating the agent daily processing execution time" is the value of the "agt_daily_sec" key included in the response body of the device registration Web API (this value is in seconds). <br>  <br> 「agt_daily_sec」の詳細に関しては「EJ03.(AdminLink) 01_ WebAPI Specifications」の <br> 「2.2.Device registration API」シートを参照。 <br> For the datail about "agt_daily_sec", refer to the sheet "2.2.Device registration API" on the document "EJ03.(AdminLink) 01_ WebAPI Specifications". <br>  <br> 日次処理を実行するタイミングに関しては、「EJ105_AdminLinkRequestSpecifications_APSW」の「AGT.2.3.2」シートを参照。 <br> For the datail about timing to Daily processing, refer to the sheet "AGT.2.3.2" on the document "EJ105_AdminLinkRequestSpecifications_APSW".

#### AGT.2.3.3
* □□□
* 日次処理の開始をログに記録する。「Log Message 」シートを参照。 <br> Log the daily processing start. See the 'Log Message' sheet.

#### AGT.2.3.10
* ＜デバイス登録状態を確認する＞ <br> ＜Check the device registration status.＞

#### AGT.2.3.11
* □□□
* デバイスの登録状態を確認する。 <br> ただし、既にデバイス登録状態を確認する処理を実行中の場合には、この処理を行わない。 <br> Check the device registration status. <br> But, if any other process to check the device registration status is ongoing, don't execute this process. <br>  <br> AGT.1.4に記載の方法で確認する <br> By same methond as one of AGT.1.4. <br>  <br> 「EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow)」の、 <br> 「1.Device entry_software flow」シートに従うこと。 <br> Follow the sheet 「1.Device entry_software flow」 on 「EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow)」

#### AGT.2.3.20
* ＜デバイスの登録状態が「確認中」の場合＞ <br> When the registration status of the device is "Checking".

#### AGT.2.3.21
* □□□
* 日次処理による登録状態確認の結果、「確認中」である事をログに記録する <br> Log the result of the registration status confirmation by daily processing as "Checking".

#### AGT.2.3.30
* ＜デバイスの登録状態が「登録済み」の場合＞ <br> ＜When the device registration status is "Registered".＞

#### AGT.2.3.31
* □□□
* 日次処理による登録状態確認の結果、「登録済み」である事をログに記録する <br> Log the result of the registration status confirmation by daily processing as "registered".

#### AGT.2.3.40
* ＜デバイスの登録状態が「未登録」の場合＞ <br> ＜When the device registration status is "Unregistered".＞

#### AGT.2.3.41
* □□□
* 定期処理を実行している場合は停止する。 <br> Stop periodical process if it is running. <br> 遠隔操作の受付を停止する。 <br> Stop remote control reception.

#### AGT.2.3.42
* □□□
* 日次処理による登録状態確認の結果、「未登録」であるため、エージェント機能を停止する事をログに記録する。「Log Message 」シートを参照。 <br> Log the fact that the agent function will stop when it is "unregistered", due to the registration status confrimation by daily processing. See the 'Log Message' sheet.

### AGT.2.4
* 要求 <br> request
* 1時間毎にデバイスのステータス情報を取得し、アドミリンクサーバーへ送信できる事。 <br> The device status information must be acquired hourly and sent to the AdminLink server.

- 理由 | ・デバイスのステータス情報を取得したい <br> Client wants to get the device status.
- 説明
#### AGT.2.4.0
* ＜1時間毎のステータスチェック開始＞ <br> ＜Start hourly status check＞

#### AGT.2.4.1
* □□□
* アドミリンク機能が有効且つ、デバイス登録状態が「登録済み」または「確認中」の場合、1時間毎に定期的に実行する。 <br> When the AdminLink function is enabled and the device registration status is "Registered" or "Checking", this function will be executed periodically every hour.

#### AGT.2.4.2
* □□□
* 毎時、00分00秒を起点として、「エージェント情報送信タイミング計算用秒数」を加算した時刻から開始し、以後、1時間毎に実行する。 <br> Starting from 00 minutes 00 seconds every hour, it starts from the time when the "number of seconds for agent information transmission timing calculation" is added, and is executed every hour thereafter. <br> 「エージェント情報送信タイミング計算用秒数」は、デバイス登録Web APIのレスポンスボディに含まれる「agt_upload_sec」キーの値である（この値は秒数）。 <br> The "number of seconds for calculating the timing for sending agent information" is the value of the "agt_upload_sec" key included in the response body of the device registration Web API (this value is in seconds). <br>  <br> 「agt_upload_sec」の詳細に関しては「EJ03.(AdminLink) 01_ WebAPI Specifications」の <br> 「2.2.Device registration API」シートを参照。 <br> For the datail about "agt_upload_sec", refer to the sheet "2.2.Device registration API" on the document "EJ03.(AdminLink) 01_ WebAPI Specifications". <br>  <br> 1時間毎の定期処理を実行するタイミングに関しては、「EJ105_AdminLinkRequestSpecifications_APSW」の「AGT.2.4.2」シートを参照。 <br> For the datail about timing to hourly status check, refer to the sheet "AGT.2.4.2" on the document "EJ105_AdminLinkRequestSpecifications_APSW".

#### AGT.2.4.3
* □□□
* 60分間隔中に「デバイス情報送信」ボタンクリックやイベント通知されたとしても60分間隔の起点は変えず、予定していた時刻にJSONデータを生成する。 <br> Generate JSON data at scheduled time, though the "Send device information" button was clicked or a event notification was sent since last JSON data generation.

#### AGT.2.4.4
* □□□
* ステータスJSONデータを作成しRAM上に保持し送信する。 <br> Create status JSON data, retain it on RAM and send it.

#### AGT.2.4.5
* □□□
* デバイス登録状態を確認する。(AGT.2.4.40 参照) <br> Check the device registration status. (Refer "AGT.2.4.40")

#### AGT.2.4.10
* ＜ステータスJSONデータの作成＞ <br> ＜Creating status JSON data＞

#### AGT.2.4.11
* □□□
* 必要な情報を取得し、ステータスJSONデータを生成する。 <br> Obtain the necessary information and generate status JSON data.

##### AGT.2.4.11.1
* □□□
* 同一時間帯で2回目以降のステータス収集の場合、保存された値から条件に合った変化のあるステータスのみ更新する。 <br> Since second information obtaining in the same time band, update only status that is changed since last time.

##### AGT.2.4.11.2
* □□□
* JSONデータは、「EJ06.(adminlink)JSON definition.xlsx」の、「ステータスJSON」に定義されている構造とする。 <br> Follow the JSON data structure defined on 「ステータスJSON」 of 「EJ06.(adminlink)JSON definition.xlsx」.

##### AGT.2.4.11.3
* □□□
* 全ステータス情報をJSONデータとして保存する。 <br> Save all status information as JSON data.

#### AGT.2.4.12
* □□□
* ステータスJSONデータ内のステータスタイプを「定期通知」（sts_type = 0）とする。 <br> Set the status type in the status JSON data to "Periodic Notification" (sts_type = 0).

#### AGT.2.4.13
* □□□
* 「ステータスチェック」の各ステータス項目の情報取得中にエラーが起きた場合、エージェントエラーにはせず、その取得失敗したステータス項目は本体内の情報を更新せず前回のままにする。 <br> When a error is occurred while gathering each items for status check, Just keep the last condition. Don't process the error as agent error. Don't update the item that we failed getting.

#### AGT.2.4.20
* ＜ステータスJSONデータの保持＞ <br> ＜Retaining status JSON data＞

#### AGT.2.4.21
* □□□
* 生成したステータスJSONデータをRAMに保持する。 <br> Generate status JSON data, and retain it on RAM.

#### AGT.2.4.30
* ＜ステータスJSONデータの送信＞ <br> ＜Sending status JSON data＞

#### AGT.2.4.31
* □□□
* RAMに保持されているJSONデータをサーバーへ送信する（AGT.2.6を参照）。 <br> Send JSON data retained on RAM to AdminLink server(refer to AGT.2.6).

#### AGT.2.4.40
* ＜デバイス登録状態を確認する＞ <br> ＜Check the device registration status.＞

#### AGT.2.4.41
* □□□
* デバイスの登録状態を確認する。 <br> ただし、既にデバイス登録状態を確認する処理を実行中の場合には、この処理を行わない。 <br> Check the device registration status. <br> But, if any other process to check the device registration status is ongoing, don't execute this process. <br>  <br> AGT.1.4に記載の方法で確認する <br> By same methond as one of AGT.1.4. <br>  <br> 「EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow)」の、 <br> 「1.Device entry_software flow」シートに従うこと。 <br> Follow the sheet 「1.Device entry_software flow」 on 「EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow)」

#### AGT.2.4.50
* ＜デバイスの登録状態を確認した結果が「登録済み」の場合＞ <br> ＜When the device registration status is "Unregistered".＞

#### AGT.2.4.51
* □□□
* 「AGT.2.4.20」で保持をしているステータスJSONを送信する。 <br> Send the status JSON held in “AGT.2.4.20”.

#### AGT.2.4.52
* □□□
* 登録状態確認の結果、「登録済み」である事をログに記録する <br> Log the result of the registration status confirmation as "registered". <br>  <br> 「Log Message 」シートを参照。 <br> See the 'Log Message' sheet.

#### AGT.2.4.60
* ＜デバイスの登録状態を確認した結果が「確認中」の場合＞ <br> ＜When the device registration status is "Checking".＞

#### AGT.2.4.61
* □□□
* 結果をログに記録する。「Log Message 」シートを参照。 <br> Log results. See the 'Log Message' sheet.

#### AGT.2.4.70
* ＜デバイスの登録状態を確認した結果が「未登録」の場合＞ <br> ＜When the device registration status is "Unregistered".＞

#### AGT.2.4.71
* □□□
* 定期処理を実行している場合は停止する。 <br> Stop periodical process if it is running. <br> 遠隔操作の受付を停止する。 <br> Stop remote control reception.

#### AGT.2.4.72
* □□□
* 1時間毎の登録状態確認の結果、「未登録」であるため、エージェント機能を停止する事をログに記録する。「Log Message 」シートを参照。 <br>  <br> Log the fact that the agent function will stop when it is "unregistered", due to the hourly registration status confrimation. See the 'Log Message' sheet.

### AGT.2.5
* 要求 <br> request
* 1分間毎のポーリングでデバイスを監視し、イベントの発生をアドミリンクサーバーへ送信できる事。 <br> Must be able to monitor the device by polling every minute and send event occurrences to the AdminLink server.

- 理由 | ・イベント監視を行いたい <br> Client wants to monitor events.
- 説明
#### AGT.2.5.0
* ＜イベントJSON検知に必要なポーリング処理を実行する＞ <br> ＜Perform the polling process required for event JSON detection＞

#### AGT.2.5.1
* □□□
* アドミリンク機能が有効且つ、デバイスが「登録済み」の場合、毎分00秒に、イベントJSONの検知に必要なステータスチェックを行う。 <br> If the AdminLink function is enabled and the device is "registered", a status check is performed every minute at 00 seconds, which is necessary to detect the event JSON.

#### AGT.2.5.2
* □□□
* 上記の周期についてはハードコーディングせず、設定ファイルで指定する。 <br> ※ポーリング周期（60秒） <br> Retain the interval (every minute at 00 seconds) on the configuration file. <br> Don't retain it by hard-coding. <br> ※Polling interval（60 seconds）

#### AGT.2.5.3
* □□□
* イベント検出した場合、イベントパケットのメッセージに指定するメッセージを生成する。 <br> 各イベントのメッセージについては、「EJ07.(adminlink)Requirement Definition Attachment-Event Definition.xlsx」を参照。 <br> When a event is detected, create a message for each event. <br> The message for each event are defined on 「EJ07.(adminlink)Requirement Definition Attachment-Event Definition.xlsx」.

#### AGT.2.5.4
* □□□
* イベントを検出していた場合、検出したイベント毎に下記ログを出力する。 <br> When a event is detected, Log it for each detected event. <br>  <br> 「Log Message 」シートを参照。 <br> See the 'Log Message' sheet.

#### AGT.2.5.10
* ＜イベント検知のエラー＞ <br> ＜Error in event detection＞

#### AGT.2.5.11
* □□□
* イベントの発生を検知（判定）するために、デバイスの情報を取得する必要がある場合で、その情報の取得に失敗した場合は、ログに記録する。 <br> In the case we need getting the device information to detect event occurring, <br> if fail getting the device information, log it.  <br>  <br> 「Log Message 」シートを参照。 <br> See the 'Log Message' sheet.

#### AGT.2.5.12
* □□□
* ステータスチェックに失敗した場合、エージェントエラーにはせず、該当するステータスのイベント検知動作をキャンセルする。 <br> When the status check is failed, just cancel the event detection for the status. Don't process it as agent error.

#### AGT.2.5.13
* □□□
* イベント検知動作をスキップするとき、その回のイベントチェックで他にイベントが検出されてもイベント検出ログは出力せず、イベントJSONデータも作成しない。 <br> When skipping event detection, don'nt log it though any other event is detected in the time. <br> And don't generate event JSON data.

#### AGT.2.5.20
* ＜イベント検知の正常終了＞ <br> ＜Successful completion of event detection＞

#### AGT.2.5.21
* □□□
* イベントの検知に成功した場合、ログは記録しない。 <br> Don't log if the event detection success.

#### AGT.2.5.30
* ＜イベントの検知＞ <br> ＜Event detection＞

##### AGT.2.5.30.1
* □□□
* 「EJ07.(adminlink)Requirement Definition Attachment-Event Definition.xlsx」の「検知項目(Detection item)」に定義された項目についてデバイスの情報を取得し、イベントの発生をチェックする。 <br> Get the device information defined on 「検知項目(Detection item)」 of 「EJ07.(adminlink)Requirement Definition Attachment-Event Definition.xlsx」, and check the event occurrences.

#### AGT.2.5.31
* □□□
* イベントを検知した場合、イベントJSONデータを生成する。 <br> When an event is detected, generate a event JSON data.

#### AGT.2.5.32
* □□□
* イベントJSONデータを作成するタイミングは、イベントの検出時とする。 <br> The timing to generate the event JSON data is when the event is detected.

#### AGT.2.5.33
* □□□
* イベントJSONデータは、「EJ06.(adminlink)JSON definition.xlsx」の、「②イベントJSONボディ」に定義されている構造とする。 <br> Folllow the structure of event JSON data defined on 「②Event JSON body」 of 「EJ06.(adminlink)JSON definition.xlsx」.

#### AGT.2.5.34
* □□□
* イベントJSONデータは、1つのイベントにつき、1つ作成する。 <br> Generate one event JSON data by one event.

#### AGT.2.5.40
* ＜イベントJSONデータの保持＞ <br> ＜Retaining event JSON data＞

#### AGT.2.5.41
* □□□
* 生成したイベントJSONデータをRAM上に保持する。 <br> Retain generated event JSON data on RAM.

#### AGT.2.5.50
* ＜ステータスJSONデータの作成＞ <br> ＜Creating status JSON data＞

#### AGT.2.5.51
* □□□
* すべてのイベントチェックが完了した後、1つ以上のイベントを検知し、イベントJSONデータを生成した場合、ステータスJSONデータを作成する。 <br> After all event checking is complete, if one or more events are detected and event JSON data is generated, status JSON data will be created.

#### AGT.2.5.52
* □□□
* ステータスJSONデータ内のステータスタイプを「イベント通知」（sts_type = 1）とする。 <br> Set the status type of the status JSON data to "event notification" (sts_type = 1).

#### AGT.2.5.53
* □□□
* 「対処必要」なイベントの「対処待ち」を検知した場合、ステータスJSONのsts[]テーブルにイベントJSONの情報を追加する。 <br> If an event that "needs action" is detected as "waiting for action", the information of the event JSON is added to the sts[] table of the status JSON.

#### AGT.2.5.54
* □□□
* 「対処必要」なイベントの「対処済み」を検知した場合、ステータスJSONのsts[]テーブルからイベントJSONの情報を削除する。 <br> If an event that "Needs to be dealt with" is detected as "Dealt with", the information of the event JSON is deleted from the sts[] table of the status JSON.

#### AGT.2.5.55
* □□□
* ステータスJSONデータを作成した場合は、RAMへ保持する。 <br> When status JSON data is created, retain it on RAM.

#### AGT.2.5.60
* ＜イベントJSONデータとステータスJSONデータの送信＞ <br> ＜Sending event JSON data and status JSON data＞

#### AGT.2.5.61
* □□□
* RAM上に保持しているJSONデータをサーバーへ送信する。 <br> Send JSON data retained on RAM to the AdminLink server.

### AGT.2.6
* 要求 <br> request
* JSONデータをアドミリンクサーバーへ送信できる事 <br> Must be able to send JSON data to the Adminlink server

- 理由 | ・各種の情報をJSON形式でアドミリンクサーバーへ送信したい <br> Client wants to send any informations to the AdminLink server as JSON format.
- 説明
#### AGT.2.6.0
* ＜JSONデータの共通仕様＞ <br> ＜Common specifications for JSON data＞

#### AGT.2.6.1
* □□□
* JSONデータの形式は、下記の通りとする。 <br> The data format of the JSON data shall be as follows <br> 　・JSON形式 <br> 　・JSON format <br> 　・文字コード: Unicode(UTF-8) <br> 　・Character code: Unicode(UTF-8) <br> 　・BOM付（0xEF, 0xBB, 0xBF） <br> 　・With BOM (0xEF, 0xBB, 0xBF) <br>   ・改行コードはLF <br>   ・The line feed code is LF. <br>  <br>  <br> 「EJ05.(AdminLink)for device side developmentRFP」の「Upload,Download Functions」シートもあわせて参照。 <br> Refer also to the sheet "Upload,Download Functions" on the document "EJ05.(AdminLink)for device side developmentRFP".

#### AGT.2.6.10
* ＜JSONデータの送信＞ <br> ＜Sending JSON data＞

#### AGT.2.6.11
* □□□
* RAM上に保持しているJSONデータをサーバーへ送信する。 <br> Send JSON data retained on RAM to AdminLink server. <br>  <br> ※「EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow)」の、「6.Status_event upload flow」シートを参照して実装する事。 <br> ※Follow the sheet 「6.Status_event upload flow」 on 「EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow)」. <br>  <br>  <br> 設定ステータスJSONデータの送信に関してはAGT.2.8.70～2.8.131を参照。 <br> About sending configuration status JSON data, refer AGT.2.8.70 - 2.8.131.

#### AGT.2.6.12
* □□□
* プロキシー設定が有効の場合、プロキシー経由で通信する。 <br> When the proxy setting is enabled, communication is done via the proxy.

#### AGT.2.6.20
* ＜JSONデータの送信成功＞ <br> ＜JSON data sent successfully＞

#### AGT.2.6.21
* □□□
* 送信を完了したJSONデータは、RAM上から削除する。 <br> After JSON data transmission complete, delete the sent JSON data from RAM.

#### AGT.2.6.30
* ＜JSONデータの送信失敗＞ <br> ＜Failed to send JSON data＞

#### AGT.2.6.31
* □□□
* 送信を完了できなかったJSONデータは削除せずRAMに残す。 <br> Don't delete the JSON data that is not sent last time. Keep it on RAM.

#### AGT.2.6.32
* □□□
* 送信エラーをログに記録する。 <br> Log transmission errors. <br> 「Log Message 」シートを参照。 <br> See the 'Log Message' sheet.

#### AGT.2.6.33
* □□□
* RAMにJSONデータが残っている場合、60秒ごとに送信をリトライする。 <br> If there is a unsent JSON data on RAM, retry sending it every 60 seconds. <br> 送信に成功したらJSONデータをRAMから削除する <br> When the JSON data transmission is successful, delete it from RAM. <br>  <br> 6回連続でリトライに失敗した場合、以降リトライを行わない。 <br> If the device fails the retry repeatedly 6 times, don't do the retry again. <br>  <br> リトライの場合も、JSONデータの送信に失敗する都度、AGT.2.6.32 のログを記録すること。 <br> A log (AGT.2.6.32) should be recorded for each failed attempt to send JSON data, even in the case of retries.

### AGT.2.7
* 要求 <br> request
* ユーザーの指定した時間毎に接続クライアントファイルを作成し、アドミリンクサーバーへ送信できる事。 <br> A connection client file can be created and sent to the AdminLink server at the time specified by the user.

- 理由 | ・指定した時間毎に接続クライアントファイルを作成したい <br> Client wants to create the connection client file every specified time.
- 説明
#### AGT.2.7.0
* ＜ユーザー指定時間毎に実行＞ <br> ＜Execute every user specified time＞

#### AGT.2.7.1
* □□□
* 「遠隔操作許可」が「有効」且つ、「接続クライアントファイルアップロード許可」が「有効」の場合のみ実行する。 <br> Execute only when "Remote control permission" is "Enabled" and "Connected client file upload permission" is "Enabled". <br> 「無効」の場合は実行しない。 <br> Do not execute if it is "Disabled".

#### AGT.2.7.2
* □□□
* 00時00分00秒に「エージェント情報送信タイミング計算用秒数」を加算した時刻を起点とし、ユーザーの指定時間毎に実行する。 <br> （例：起点が 00:15:30、6時間毎に設定した場合、実行時刻は 00:15:30, 06:15:30, 12:15:30, 18:15:30） <br> The starting point is the time 00:00:00 + the value of "number of seconds for calculating the timing of agent information transmission", and thereafter it is executed every time specified by the user. <br> (For example, the case of starting point 00:15:30 and interval every 6 hours, the execute times are 00:15:30, 06:15:30, 12:15:30 and 18:15:30.) <br>  <br> 設定後、および（再）起動後の最初の実行は、実行時刻の中で一番近い時刻に行う。 <br> （例：起点が 00:15:30、6時間毎に設定した場合、設定を適用した時刻が 18:00:00 であった場合、次の実行時刻は 18:15:30） <br> The first execution after user set/changed the configuration or device booted/rebooted, is at the closest to the one of the execution time. <br> (For example, the case of starting point 00:15:30 and interval every 6 hours, if the user set/changed the configuration at 18:00:00, the next execute time is 18:15:30)  <br>  <br> 「エージェント情報送信タイミング計算用秒数」は、デバイス登録Web APIのレスポンスボディに含まれる「agt_upload_sec」キーの値である（この値は秒数）。 <br> The "number of seconds to calculate the timing for sending agent information" is the value of the "agt_upload_sec" key included in the response body of the device registration Web API (this value is in seconds). <br>  <br> 「agt_upload_sec」の詳細に関しては「EJ03.(AdminLink) 01_ WebAPI Specifications」の <br> 「2.2.Device registration API」シートを参照。 <br> For the datail about "agt_upload_sec", refer to the sheet "2.2.Device registration API" on the document "EJ03.(AdminLink) 01_ WebAPI Specifications". <br>  <br> ファイルをアップロードするタイミングの詳細に関しては「EJ105_AdminLinkRequestSpecifications_APSW」の「AGT.2.7.2」シートを参照。 <br> For the datail about timing to upload file, refer to the sheet "AGT.2.7.2" on the document "EJ105_AdminLinkRequestSpecifications_APSW".

#### AGT.2.7.10
* ＜接続クライアントファイルの作成＞ <br> ＜Create a connection client file＞

#### AGT.2.7.11
* □□□
* デバイスの接続クライアント情報を取得し、CSV形式のデータを作成する。 <br> ファイルフォーマットはUTF-8（BOM付）とする。 <br> Obtain the connection client information of the device and create the data by CSV format. <br> The file format is UTF-8 with BOM. <br>  <br> APは下記の情報を含める事。 <br> 　・MAC Address <br> 　・RSSI <br> 　・TX Rate (Mbit/sec.) <br> 　・RX RAte (Mbit/sec.) <br>  <br> スイッチは下記の情報を含める事。 <br> 　・VLAN <br> 　・MAC Address <br> 　・Port <br> 　スイッチ Web UI のMACアドレステーブル>>動的アドレステーブルの情報とする。 <br> 　データの並び順は、Web UIに合わせる事。 <br> 　タイトルは日本語とする。 <br> 　Define the Switchs 'Connection client information file' as a MAC forwarding Table. <br> 　The order of the data should be the same as the Web UI. <br> 　The title should be in Japanese. <br>  <br> 接続クライアントファイルの詳細に関しては「EJ05.(AdminLink)for device side developmentRFP」の「Upload,Download Functions」シートを参照。 <br> For the datail about device connection client file, refer to the sheet "Upload,Download Functions" on the document "EJ05.(AdminLink)for device side developmentRFP".

#### AGT.2.7.20
* ＜接続クライアントファイルの作成失敗＞ <br> ＜Failed to create connection client file＞

#### AGT.2.7.21
* □□□
* 接続クライアントファイルの作成に失敗した場合はログに記録する。 <br> Log if the creation of the connection client file fails. <br>  <br> 「Log Message 」シートを参照。 <br> See the 'Log Message' sheet.

#### AGT.2.7.30
* ＜接続クライアントファイルの作成成功＞ <br> ＜Successful creation of connection client file＞

#### AGT.2.7.31
* □□□
* ＜接続クライアントファイルのアップロード＞処理を実行する。 <br> Execute the ＜Uploading the connected client file＞ process.

#### AGT.2.7.40
* ＜接続クライアントファイルのアップロード＞ <br> ＜Uploading the connected client file＞

#### AGT.2.7.41
* □□□
* ファイルアップロード用URL取得 Web APIで、アップロード用のURLを取得する。 <br> Obtain the upload URL using the Web API for obtaining the file upload URL.

#### AGT.2.7.42
* □□□
* プロキシー設定が有効の場合、プロキシー経由で通信する。 <br> When the proxy setting is enabled, communication is done via the proxy.

#### AGT.2.7.40A
* ＜アップロードURLの取得に成功＞ <br> ＜Successfully retrieved upload URL.＞

#### AGT.2.7.43
* □□□
* 取得したURLへ接続クライアントファイルをアップロードする。 <br> Upload the connection client file to the URL you obtained. <br>  <br> プロトコルに関しては「EJ05.(AdminLink)for device side developmentRFP」の「Upload,Download Functions」シートを参照。 <br> About the protocol, refer to the sheet "Upload,Download Functions" on the document "EJ05.(AdminLink)for device side developmentRFP". <br>  <br> ファイルアップロード処理は以下のフローに従う <br> 「EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow).xlsx」の <br> 「8.File upload flow」 <br> The file upload process is followed by the sheet 「8.File upload flow」 on 「EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow).xlsx」.

#### AGT.2.7.40B
* ＜アップロードURLの取得に失敗＞ <br> ＜Failed to retrieve upload URL.＞

#### AGT.2.7.41B
* □□□
* ファイルアップロード用URL取得 Web APIが失敗した場合、ログに記録する。 <br> Log if the Web API to retrieve File Upload URL fails. <br>  <br> 「Log Message 」シートを参照。 <br> See the 'Log Message' sheet.

#### AGT.2.7.40C
* ＜接続クライアントファイルのアップロード成功＞ <br> ＜Successful upload of  connection client file.＞

#### AGT.2.7.44
* □□□
* アップロード完了後、ファイルアップロード完了通知 Web APIをコールしてアドミリンクサーバーへアップロードの完了を通知する。 <br> After the upload is complete, the file upload completion notification Web API is called to notify the AdmLink server of the completion of the upload. <br> ・ファイルアップロード種別（upload_type）は04（接続クライアントファイル）とする。 <br> ・The file upload type (upload_type) shall be 04 (connection client file). <br> ・拡張子（extension）は "csv" とする。 <br> ・The extension shall be "csv". <br> ・定期処理によるアップロードの場合は自動アップロードフラグ（auto_flg）を 1 （自動）に設定する。 <br> ・In the case of upload by periodical process, set the automatic upload flag (auto_flg) to 1 (automatic). <br>  <br> 【参考】遠隔操作リクエストによるアップロードの場合は自動アップロードフラグ（auto_flg）を 0 （手動）に設定する。 <br> When uploading by remote control request, set the auto_flg flag to 0 (manual).

#### AGT.2.7.50
* ＜接続クライアントファイルのアップロード成功＞ <br> ＜Successfully uploaded connection client file＞

#### AGT.2.7.51
* □□□
* 接続クライアントファイルのアップロードに成功した場合はログに記録しない。 <br> Don't Log if the connection client file is successfully uploaded.

#### AGT.2.7.60
* ＜接続クライアントファイルのアップロード失敗＞ <br> ＜Failed to upload connection client file.＞

#### AGT.2.7.61
* □□□
* 接続クライアントファイルのアップロードに失敗した場合はログに記録する。 <br> Log if the upload of the connection client file failed to upload. <br>  <br> 「Log Message 」シートを参照。 <br> See the 'Log Message' sheet.

#### AGT.2.7.70
* ＜ファイルアップロード完了通知Web API失敗＞ <br> ＜File upload completion notification Web API failure＞

#### AGT.2.7.71
* □□□
* ファイルアップロード完了通知Web API の実行に失敗した場合、ログに記録する。 <br> Log it the execution of the file upload completion notification Web API fails. <br> 「Log Message 」シートを参照。 <br> See the 'Log Message' sheet.

### AGT.2.8
* 要求 <br> request
* Web UI の設定変更の適用を監視し、設定が変更されたらアドミリンクサーバーへ設定ファイルを送信できる事。 <br> Must be able to monitor Web UI configuration changes and send configuration file to the AdminLink server when the configuration is changed.

- 理由 | ・設定変更したことをサーバーに伝えたい <br> Client wants to notify a configuration change to AdminLink server.
- 説明
#### AGT.2.8.0
* ＜Web UIの設定変更が適用された事を検知する＞ <br> ＜Detects that Web UI configuration changes have been applied.＞

##### AGT.2.8.0.1
* □□□
* アドミリンク機能が有効で、「設定ファイルアップロード許可」が「有効」な場合、または「無効」から「有効」に変化した場合、Web UIの設定変更を監視する。 <br> When the AdminLink function is enabled, and "Configuration file upload permission" is "Enabled" or changed from "Disabled" to "Enabled", monitor the Web UI configuration changes.

#### AGT.2.8.1
* □□□
* デバイスのWeb UI で設定変更が適用されたことを検知する。 <br> Detects that a configuration change has been applied in the device's Web UI.

#### AGT.2.8.10
* ＜デバイスの設定ファイルをアップロードする＞ <br> ＜Upload the device configuration file.＞

#### AGT.2.8.11
* □□□
* 「遠隔操作許可」が「有効」且つ、「設定ファイルアップロード許可」が「有効」の場合のみ実行する。 <br> This function is executed only when "Remote control permission" is "Enabled" and "Configuration file upload permission" is "Enabled". <br> 「無効」の場合は実行しない。 <br> If "Disabled", it will not be executed.

##### AGT.2.8.11.1
* □□□
* 変更を検知したら、デバイス設定ファイルを作成する <br> When a Web UI configuration change is detected, create device configuration file. <br> デバイス設定ファイルは、Web UIの「バックアップ/復元」で作成するファイル <br> The device configuration file is same as one created by 「バックアップ/復元」 on Web UI. <br>  <br> デバイス設定ファイルの詳細に関しては「EJ05.(AdminLink)for device side developmentRFP」の「Upload,Download Functions」シートを参照。 <br> For the datail about device configuration file, refer to the sheet "Upload,Download Functions" on the document "EJ05.(AdminLink)for device side developmentRFP".

##### AGT.2.8.11.2
* □□□
* 作成が成功したら、アドミリンクサービスへアップロードする。 <br> After device configuration file creation complete, upload it to the AdminLink server. <br>  <br> ファイルアップロード処理は以下のフローに従う <br> 「EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow).xlsx」の <br> 「8.File upload flow」 <br> The file upload process is followed by the sheet 「8.File upload flow」 on 「EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow).xlsx」.

#### AGT.2.8.12
* □□□
* ファイルアップロード用URL取得 Web APIで、アップロード用のURLを取得する。 <br> Obtain the upload URL using the Web API for obtaining the file upload URL.

#### AGT.2.8.20
* ＜アップロードURLの取得に成功＞ <br> ＜Successfully retrieved upload URL.＞

#### AGT.2.8.21
* □□□
* 取得したURLへデバイス設定ファイルをアップロードする。 <br> Upload the device configuration file to the URL you obtained. <br>  <br> プロトコルに関しては「EJ05.(AdminLink)for device side developmentRFP」の「Upload,Download Functions」シートを参照。 <br> About the protocol, refer to the sheet "Upload,Download Functions" on the document "EJ05.(AdminLink)for device side developmentRFP". <br>  <br> ファイルアップロード処理は以下のフローに従う <br> 「EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow).xlsx」の <br> 「8.File upload flow」 <br> The file upload process is followed by the sheet 「8.File upload flow」 on 「EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow).xlsx」.

#### AGT.2.8.30
* ＜アップロードURLの取得に失敗＞ <br> ＜Failed to retrieve upload URL.＞

#### AGT.2.8.31
* □□□
* ファイルアップロード用URL取得 Web APIが失敗した場合、ログに記録する。 <br> Log if the Web API to retrieve File Upload URL fails. <br>  <br> 「Log Message 」シートを参照。 <br> See the 'Log Message' sheet.

#### AGT.2.8.40
* ＜デバイスの設定ファイルのアップロード成功＞ <br> ＜Successful upload of device configuration file.＞

#### AGT.2.8.41
* □□□
* アップロード完了後、ファイルアップロード完了通知 Web APIをコールしてアドミリンクサーバーへアップロードの完了を通知する。 <br> After the upload is complete, call the file upload completion notification Web API to notify the Admirink server of the completion of the upload. <br> ・ファイルアップロード種別（upload_type）は03（設定ファイル）とする。 <br> ・The file upload type (upload_type) shall be 03 (configuration file). <br> ・拡張子（extension）は 設定ファイルの拡張子を指定する。 <br> ・The extension specifies the extension of the configuration file. <br> ・自動アップロードフラグ（auto_flg）を 1 （自動）に設定する。 <br> ・Set the auto upload flag (auto_flg) to 1 (automatic). <br>  <br> 【参考】遠隔操作リクエストによるアップロードの場合は自動アップロードフラグ（auto_flg）を 0 （手動）に設定する。 <br> When uploading by remote control request, set the automatic upload flag (auto_flg) to 0 (manual).

#### AGT.2.8.42
* □□□
* アップロードが成功した場合、ログを出力する。 <br> After the upload is successful, log the message. <br>  <br> 「Log Message 」シートを参照。 <br> See the 'Log Message' sheet.

#### AGT.2.8.50
* ＜デバイスの設定ファイルのアップロード失敗＞ <br> ＜Failed to upload device configuration file.＞

#### AGT.2.8.51
* □□□
* デバイスの設定ファイルのアップロードを実行後、実行結果をログに記録する。 <br> Log the execution result after the device configuration file upload is executed. <br>  <br> 「Log Message 」シートを参照。 <br> See the 'Log Message' sheet.

#### AGT.2.8.60
* ＜ファイルアップロード完了通知Web API失敗＞ <br> ＜File upload completion notification Web API failure＞

#### AGT.2.8.61
* □□□
* ファイルアップロード完了通知Web API の実行に失敗した場合、ログに記録する。 <br> Log it the execution of the file upload completion notification Web API fails. <br> 「Log Message 」シートを参照。 <br> See the 'Log Message' sheet.

#### AGT.2.8.70
* ＜設定ステータスJSONデータを作成する＞ <br> ＜Create a configuration status JSON data＞

#### AGT.2.8.71
* □□□
* 設定ステータスJSONデータの項目に含まれる設定が変更された場合、設定ステータスJSONデータを作成する。 <br> When the settings included in the configuration status JSON is changed, create configuration status JSON data. <br> 既にデータが存在する場合は、変更部分のみ更新する。 <br> If the configuration status JSON data has already existed, update the changed part on the JSON data. <br>  <br> 「EJ06.(adminlink)JSON definition.xlsx」ファイルの、「JSON definition」シートの「Configuration status JSON body (AP/SWITCH common)」の記載に従う <br> Follow 「Configuration status JSON body (AP/SWITCH common)」 on the sheet 「JSON definition」 of 「EJ06.(adminlink)JSON definition.xlsx」 <br>  <br> 「遠隔操作許可」および「設定ファイルアップロード許可」の設定とは関係なく、設定ステータスJSONの項目に含まれる設定が変更された場合は常に実行する。 <br> Regardless of the "Remote control permission" and "Configuration file upload permission" settings, it is always executed when the settings included in the configuration status JSON change.

#### AGT.2.8.80
* ＜設定ステータスJSONデータをアップロードする＞ <br> ＜Upload the configuration status JSON data＞

#### AGT.2.8.81
* □□□
* 設定ステータスJSONデータが作成されたら、ファイルアップロード用URL取得 Web APIで、アップロード用のURLを取得する。 <br> After the configuration status JSON data has been created, obtain the upload URL using the Web API for URL acquisition for file upload.

#### AGT.2.8.90
* ＜ファイルアップロードURLの取得に成功した場合＞ <br> ＜Successfully retrieved upload URL.＞

#### AGT.2.8.91
* □□□
* 取得したURLへ設定ステータスJSONデータをアップロードする。 <br> Upload the configuration status JSON data to the obtained URL. <br>  <br> プロトコルに関しては「EJ05.(AdminLink)for device side developmentRFP」の「Upload,Download Functions」シートを参照。 <br> About the protocol, refer to the sheet "Upload,Download Functions" on the document "EJ05.(AdminLink)for device side developmentRFP". <br>  <br> ファイルアップロード処理は以下のフローに従う <br> 「EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow).xlsx」の <br> 「8.File upload flow」 <br> The file upload process is followed by the sheet 「8.File upload flow」 on 「EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow).xlsx」.

#### AGT.2.8.100
* ＜ファイルアップロードURLの取得に失敗した場合＞ <br> ＜Failed to retrieve upload URL.＞

#### AGT.2.8.101
* □□□
* ファイルアップロード用URL取得 Web APIが失敗した場合、ログに記録する。 <br> Log if the Web API to retrieve File Upload URL fails. <br>  <br> リトライせず、処理を終了する <br> No retry, just exit the process. <br>  <br> 「Log Message 」シートを参照。 <br> See the 'Log Message' sheet.

#### AGT.2.8.110
* ＜設定ステータスJSONデータのアップロード成功＞ <br> ＜Configuration status JSON data uploaded successfully.＞

#### AGT.2.8.111
* □□□
* アップロード完了後、ファイルアップロード完了通知 Web APIをコールしてアドミリンクサーバーへアップロードの完了を通知する。 <br> After the upload is complete, call the File Upload Completion Notification Web API to notify the AdminLink server of the completion of the upload. <br> ・ファイルアップロード種別（upload_type）は05（設定ステータスJSONファイル）とする。 <br> The file upload type (upload_type) shall be 05 (set status JSON file). <br> ・拡張子（extension）は "json" とする。 <br> The extension is set to "json". <br> ・自動アップロードフラグ（auto_flg）を 1 （自動）に設定する。 <br> Set the automatic upload flag (auto_flg) to 1 (automatic).

#### AGT.2.8.120
* ＜設定ステータスJSONデータのアップロード失敗＞ <br> ＜Failed to upload configuration status JSON data.＞

#### AGT.2.8.121
* □□□
* 設定ステータスJSONファイルのアップロードを実行後、実行結果をログに記録する。 <br> Log the results of the execution after uploading the configuration status JSON file. <br>  <br> 「Log Message 」シートを参照。 <br> See the 'Log Message' sheet.

#### AGT.2.8.130
* ＜ファイルアップロード完了通知Web API失敗＞ <br> ＜File upload completion notification Web API failure＞

#### AGT.2.8.131
* □□□
* ファイルアップロード完了通知Web API の実行に失敗した場合、ログに記録する。 <br> Log it the execution of the file upload completion notification Web API fails. <br>  <br> 「Log Message 」シートを参照。 <br> See the 'Log Message' sheet.

#### AGT.2.8.140
* ＜ステータスJSONデータの作成と送信＞ <br> ＜Create and send status JSON data＞

#### AGT.2.8.141
* □□□
* 遠隔操作に関する下記の設定が変更された場合、ステータスJSONデータをRAMに生成して保持し、アドミリンクサーバーへ送信する。 <br> When the following settings related to remote control are changed, status JSON data will be generated, retained on the RAM, and sent to the AdminLink server. <br> ※「JSONデータをアドミリンクサーバーへ送信できる事」を参照 <br> ※See "Being able to send JSON data to the AdminLink server". <br>  <br> ・遠隔操作許可 <br> Remote control permission <br> ・設定ファイルアップロード許可 <br> Configuration file upload permission <br> ・ログファイルアップロード許可 <br> Log file upload permission <br> ・接続クライアントファイルアップロード許可 <br> Connection client file upload permission <br> ・接続クライアントファイル自動アップロード間隔 <br> Automatic upload interval for connection client files <br>  <br> 「遠隔操作許可」の設定とは関係なく、上記の設定が変更された場合は常に実行する。 <br> Regardless of the setting of "Remote control permission", it is always executed when the above settings are changed.

#### AGT.2.8.150
* ＜設定変更監視の終了＞ <br> Configuration change monitering completion

#### AGT.2.8.151
* □□□
* 下記の場合、設定の監視を終了する <br> In the case of the following, stop monitering the configuration changes. <br>  <br> ・アドミリンクエージェントが「無効」になったとき、設定の監視を終了する。 <br> ・When the AdminLink function becomes "Disabled". <br> ・「設定ファイルアップロード許可」が「無効」になったとき、設定の監視を終了する。 <br> ・When "Configuration file upload permission" becomes "Disabled". <br> ・デバイス登録が解除されたとき、設定の監視を終了する。 <br> ・When the device registration is deleted.

## AGT.3
* 要求 <br> request
* アドミリンクサーバーからの遠隔操作要求を受信し、リクエストを実行し、結果を返信できること。 <br> Must be able to receive remote control requests from AdminLink servers, execute requests, and reply results.

- 理由 | ・遠隔操作を行いたい <br> Client wants to remote control.
- 説明
### AGT.3.1
* 要求 <br> request
* アドミリンク機能が有効且つ登録済みの間、アドミリンクサーバーからの遠隔操作リクエストを受信できること。 <br> Must be able to receive remote control requests from the AdminLink server while the AdminLink function is enabled and registered.

- 理由 | ・遠隔操作リクエストを受信したい <br> Client wants to receive remote control request.
- 説明
#### AGT.3.1.0
* ＜遠隔操作受付開始＞ <br> ＜Start remote control reception＞

#### AGT.3.1.1
* □□□
* エージェント機能の開始時及び登録完了時、下記の条件を満たす場合に「遠隔操作指示受信待ち」になる <br> When AdminLink agent starts or finish the device registration, if the following condition met, it will be on "remote control reception".  <br> 　・デバイス登録状態が「登録済み」 <br> 　・The device registration status is "registered". <br>  <br> 「遠隔操作指示受信待ち」状態への遷移は「EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow).xlsx」の「7.Remote control reception flow」シートの通りに実装されていること <br> About remote control reception, follow the sheet 「7.Remote control reception flow」 on 「EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow).xlsx」 <br>  <br> ※「遠隔操作許可」が「無効」でも、上記の条件を満たす場合は、「遠隔操作指示受信待ち」になる。 <br> ※If "Remote Control Permission" is "Disabled", but the above condition met, AdminLink agent will be on "remote control reception".

#### AGT.3.1.2
* □□□
* プロキシー設定が有効の場合、プロキシー経由で通信する。 <br> When the proxy setting is enabled, communication is done via the proxy.

#### AGT.3.1.3
* □□□
* デバイス登録状態が「登録済み」以外の状態から「登録済み」に変化した場合、遠隔操作の受付を開始する。 <br> Start remote control reception, if the device registration status changes from something except "registered" to "registered,"

#### AGT.3.1.4
* □□□
* 通信エラー等で遠隔操作の受付が停止してしまった場合は、即座に遠隔操作の受付を再開する。 <br> Remote control reception will resume immediately, if remote control reception stops due to communication errors, etc.,

#### AGT.3.1.10
* ＜遠隔操作受付開始の成功＞ <br> ＜Remote control reception successfully starts＞

#### AGT.3.1.11
* □□□
* 遠隔操作受付を開始した事をログに記録する。 <br> Log the start of remote control reception. <br> 「Log Message 」シートを参照。 <br> See the 'Log Message' sheet.

#### AGT.3.1.20
* ＜遠隔操作受付開始の失敗＞ <br> ＜remote control reception fail to start＞

#### AGT.3.1.21
* □□□
* アドミリンク機能が有効で、デバイス登録状態が「登録済み」の間、遠隔操作受付が成功するまでリトライする。 <br> While the AdminLink function is enabled and the device registration status is "Registered", the system will retry until the remote control reception is successful.

#### AGT.3.1.22
* □□□
* 遠隔操作受付の開始に失敗した事をログに記録する。 <br> Logs that the remote control receptionn failed to start. <br> 「Log Message 」シートを参照。 <br> See the 'Log Message' sheet.

#### AGT.3.1.30
* ＜遠隔操作受付終了＞ <br> ＜Remote control reception closed＞

#### AGT.3.1.31
* □□□
* 下記の時に遠隔操作の受付を終了する。 <br> The remote control reception is terminated in the following cases. <br> ・Web UI でアドミリンク機能が有効から無効に変更された時。 <br> ・When the AdminLink function changes from enabled to disabled in the Web UI. <br> ・デバイスの登録が解除された時。 <br> ・When the device registration is canceled.

#### AGT.3.1.40
* ＜遠隔操作受付終了の成功＞ <br> ＜Remote control reception successfully closed＞

#### AGT.3.1.41
* □□□
* 遠隔操作受付終了を完了した事をログに記録する。 <br> Log the completion of remote control reception. <br> 「Log Message 」シートを参照。 <br> See the 'Log Message' sheet.

#### AGT.3.1.50
* ＜遠隔操作受付終了の失敗＞ <br> ＜Remote control reception fails to close＞

#### AGT.3.1.51
* □□□
* 遠隔操作受付終了に失敗した事をログに記録する。 <br> Log that remote control reception failed to close. <br> 「Log Message 」シートを参照。 <br> See the 'Log Message' sheet.

#### AGT.3.1.60
* ＜遠隔操作受付の切断を検知する＞ <br> ＜Detects disconnection of remote control reception＞

#### AGT.3.1.61
* □□□
* 遠隔操作受付が切断した事をログに記録する。 <br> Log that remote control reception is disconnected. <br> 「Log Message 」シートを参照。 <br> See the 'Log Message' sheet.

#### AGT.3.1.62
* □□□
* 遠隔操作受付を開始する。 <br> Start remote control reception.

#### AGT.3.1.70
* ＜遠隔操作の実行＞ <br> ＜Perform remote control＞

#### AGT.3.1.71
* □□□
* 遠隔操作のリクエストを受信した時、「遠隔操作許可」が「有効」の場合は、受信した遠隔操作IDの処理を実行する。 <br> Process the received remote control ID,  if "Remote Control Permission" is "Enabled" when receiving a remote control request .

#### AGT.3.1.72
* □□□
* 遠隔操作のリクエストを受信した時、「遠隔操作許可」が「無効」の場合は、受信した遠隔操作ID5010（遠隔操作許可）のみを実行する。他の遠隔操作IDは実行せず、遠隔操作のリクエストに対してアドミリンクサーバー側へエラーを返す。 <br> Only the received remote operation ID 5010 (Remote Operation Permission) is executed if "Remote Operation Permission" is "Disabled" when receiving a remote control request . Other remote control IDs will not be executed, and an error will be returned to the AdminLink server side for the remote control request. <br>  <br> ＜遠隔操作の実行失敗＞処理を実行する。(AGT3.1.90) <br> Execute the ＜Failed to execute remote control＞ process.

#### AGT.3.1.73
* □□□
* サポート外の遠隔操作IDを受信した場合は、遠隔操作のリクエストに対してアドミリンクサーバー側へエラーを返す。 <br> If an unsupported remote control ID is received, an error will be returned to the AdminLink server side for the remote control request. <br>  <br> ＜遠隔操作の実行失敗＞処理を実行する。(AGT3.1.90) <br> Execute the ＜Failed to execute remote control＞ process.

#### AGT.3.1.74
* □□□
* 遠隔操作ID（4020）「ログファイルのアップロード」を受信した場合、下記の条件を満たす場合のみ実行する。条件を満たさない場合は実行せず、アドミリンクサーバー側へエラーを返す。 <br> When remote control ID (4020) "Upload Log File" is received, it is executed only when the following conditions are met. If the condition is not met, the operation is not executed and an error is returned to the AdminLink server side. <br> 　・「遠隔操作許可」が「有効」 <br> 　・"Remote control permission" is "enabled". <br> 　・「ログファイルアップロード許可」が「有効」 <br> 　・"Log file upload permission" is "enabled". <br>  <br> ＜遠隔操作の実行失敗＞処理を実行する。(AGT3.1.90) <br> Execute the ＜Failed to execute remote control＞ process.

#### AGT.3.1.75
* □□□
* 遠隔操作ID（4030）「設定ファイルのアップロード」を受信した場合、下記の条件を満たす場合のみ実行する。条件を満たさない場合は実行せず、アドミリンクサーバー側へエラーを返す。 <br> When the remote control ID (4030) "Upload Configuration File" is received, it is executed only when the following conditions are met. If the condition is not met, the function is not executed and an error is returned to the AdminLink server side. <br> 　・「遠隔操作許可」が「有効」 <br> 　・"Remote control permission" is "enabled". <br> 　・「設定ファイルアップロード許可」が「有効」 <br> 　・"Configuration file upload permission" is "enabled". <br>  <br> ＜遠隔操作の実行失敗＞処理を実行する。(AGT3.1.90) <br> Execute the ＜Failed to execute remote control＞ process.

#### AGT.3.1.76
* □□□
* 遠隔操作ID（4040）「接続クライアントファイルのアップロード」を受信した場合、下記の条件を満たす場合のみ実行する。条件を満たさない場合は実行せず、アドミリンクサーバー側へエラーを返す。 <br> When remote control ID (4040) "Upload connection client file" is received, it is executed only if the following conditions are met. If the condition is not met, the operation is not executed and an error is returned to the AdminLink server side. <br> 　・「遠隔操作許可」が「有効」 <br> 　・"Remote control permission" is "enabled". <br> 　・「接続クライアントファイルアップロード許可」が「有効」 <br> 　・"Connected client file upload permission" is "enabled". <br>  <br> ＜遠隔操作の実行失敗＞処理を実行する。(AGT3.1.90) <br> Execute the ＜Failed to execute remote control＞ process.

#### AGT.3.1.77
* □□□
* 遠隔操作コマンドの種類と処理内容については「Remote control ID spec list」シートを参照。 <br> About the kind of remote control and the process, see the sheet 「Remote control ID spec list」.

#### AGT.3.1.80
* ＜遠隔操作の実行成功＞ <br> ＜Successful execution of remote control＞

#### AGT.3.1.81
* □□□
* 遠隔操作IDに示される処理の実行が成功した場合、実行の完了をログに記録する。 <br> Log the completion of the execution, if the process indicated by the remote control ID is successfully executed. <br> 「Log Message 」シートを参照。 <br> See the 'Log Message' sheet.

#### AGT.3.1.82
* □□□
* 下記のイベントJSONをアドミリンクサーバーへ送信する。 <br> Send the following event JSON to the AdminLink server. <br> アクションID（8010）遠隔操作実行正常終了 <br> Action ID (8010) Remote control execution successfully completed

#### AGT.3.1.83
* □□□
* システム再起動を指示する遠隔操作指示の場合、システム再起動後にアクションID(8010)遠隔操作実行正常終了と、「ウォームスタート（再起動）Warm start（restart）」（1160）イベントJSONをサーバーへ送信する。 <br> In the case of a remote control to reboot the device, before reboot the device, send Action ID (8010) and event JSON data 「Warm start(restart)」(1160) to the AdminLink server.

#### AGT.3.1.90
* ＜遠隔操作の実行失敗＞ <br> ＜Remote control failed to execute＞

#### AGT.3.1.91
* □□□
* 遠隔操作IDに示される処理の実行が失敗した場合、エラーをログに記録する。 <br> Log the error if the execution of the process indicated by the remote control ID fails. <br> 「Log Message 」シートを参照。 <br> See the 'Log Message' sheet.

#### AGT.3.1.92
* □□□
* 下記のイベントJSONをアドミリンクサーバーへ送信する。 <br> Send the following event JSON to the AdminLink server. <br> アクションID（8020）遠隔操作実行エラー <br> Action ID (8020) Remote control execution error

### AGT.3.2
* 要求 <br> request
* サーバーからのファイルダウンロードが必要な遠隔操作リクエストを処理できること。 <br> Functions requested via remote operation (including file downloads) shall be executable.

- 理由 | ファームウェアアップデートや設定変更など、サーバーからのファイルダウンロードが必要な遠隔操作を実行したい。 <br> I want to perform remote operations that require downloading files from a server, such as firmware updates and configuration changes.
- 説明
#### AGT.3.2.0
* ＜遠隔操作情報の受信と解析＞ <br> ＜Receive and analyze remote control information＞

#### AGT.3.2.1
* □□□
* サーバーから受信した遠隔操作情報で、対象の「遠隔操作ID」か否かチェックすること。 <br> Remote operation information received from the server shall be checked to see if it is the target "remote operation ID" or not. <br>  <br> 対象の遠隔操作ID <br> Target Remote Operation ID <br> 　・ファームウェアアップデート（2010） <br> 　　Firmware update <br> 　・設定変更（5070） <br> 　　Change Settings <br> 　・設定復元（5080） <br> 　　Restore Settings <br>  <br> また、遠隔操作情報に含まれている「ファイルダウンロードID」と「ファイルハッシュ値」をRAM上に保持すること。 <br> The "file download ID" and "file hash value" included in the remote operation information shall be retained in RAM.

#### AGT.3.2.2
* □□□
* RAM上に保持している「ファイルダウンロードID」を指定して、「ファイルダウンロード用URL取得 Web API」をコールし、ファイルダウンロード用のURLを取得する。 <br> Obtain the upload URL by specifing the file "download ID",  and calling the "Web API for obtaining the file upload URL".

#### AGT.3.2.10
* ＜ファイルダウンロード用URL取得 Web API 成功＞ <br> ＜Web API for obtaining the file upload URL successrully obtained＞

#### AGT.3.2.11
* □□□
* 取得したURLからファイルをダウンロードする。 <br> Download the file from the URL obtained.

#### AGT.3.2.20
* ＜ファイルダウンロード用URL取得 Web API 失敗＞ <br> ＜Web API for obtaining the file upload URL fails to obtain＞

#### AGT.3.2.21
* □□□
* 「ファイルダウンロード用URL取得 Web API」が失敗した場合はログに記録する。 <br> Log if the Web API for obtaining the file upload URL fails to obtain. <br>  <br> 「Log Message 」シートを参照。 <br> See the 'Log Message' sheet.

#### AGT.3.2.22
* □□□
* ＜遠隔操作の実行失敗＞処理を実行する。(AGT3.1.90) <br> Execute the ＜Failed to execute remote control＞ process.

#### AGT.3.2.30
* ＜ファイルダウンロード成功＞ <br> ＜Successfully downloaded file＞

#### AGT.3.2.31
* □□□
* RAM上に保持している「ファイルダウンロードID」を指定して、「ファイルダウンロード完了通知 Web API」をコールする。 <br> Specify the file download ID and call the file download completion notification Web API.

#### AGT.3.2.32
* □□□
* RAM上に保持している「ファイルハッシュ値」と、ダウンロードしたファイルのハッシュ値を照合し、一致している場合は＜ダウンロードしたファイルのハッシュ値が正しい＞を、一致していない場合は＜ダウンロードしたファイルのハッシュ値が不正＞を実行する。 <br> Checks the hash value of the downloaded file against the "file hash value" held in RAM, and if they match, executes "the hash value of the downloaded file is correct"; if they do not match, executes "the hash value of the downloaded file is incorrect".

#### AGT.3.2.40
* ＜ファイルダウンロード失敗＞ <br> <Failed to download file >

#### AGT.3.2.41
* □□□
* ファイルダウンロードに失敗した場合はログに記録する。 <br> Log if file fails to download. <br> 「Log Message 」シートを参照。 <br> See the 'Log Message' sheet.

#### AGT.3.2.42
* □□□
* ＜遠隔操作の実行失敗＞処理を実行する。(AGT3.1.90) <br> Execute the ＜Failed to execute remote control＞ process.

#### AGT.3.2.50
* ＜ダウンロードしたファイルのハッシュ値が正しい＞ <br> ＜The hash value of the downloaded file is correct.＞

#### AGT.3.2.51
* □□□
* ダウンロードしたファイルを使い、遠隔操作IDに対応した処理を実行する。 <br> Use the downloaded file to execute the process corresponding to the remote operation ID. <br>  <br> 実行に成功した場合は＜ダウンロードしたファイルの遠隔操作処理に成功＞を実行すること。 <br> If the execution is successful, <Successful remote control processing of the downloaded file> shall be executed. <br>  <br> 実行に失敗した場合は＜ダウンロードしたファイルの遠隔操作処理に失敗＞を実行すること。 <br> If execution fails, <Remote operation processing of downloaded file failed> should be executed. <br>  <br> ・「ファームウェアアップデート（2010）」の場合、ダウンロードした「ファームウェア」ファイルで、デバイスのF/Wアップデートを実行する。 <br> In case of "Firmware Update (2010)", perform F/W update of the device with the downloaded "firmware" file. <br>  <br> ・「設定変更（5070）」の場合、ダウンロードした「設定データJSON」ファイルで、デバイスの設定変更を実行する。 <br> For "Configuration Change (5070)," the downloaded "Configuration Data JSON" file is used to execute the device configuration change. <br>  <br> ・「設定復元（5080）」の場合、ダウンロードした「設定情報」ファイル（*.bin or *.cfg）でデバイスの設定を復元する。 <br> For "Configuration Restore (5080)", use the downloaded "Configuration Information" file (*.bin or *.cfg) to restore the device settings.

#### AGT.3.2.60
* ＜ダウンロードしたファイルのハッシュ値が不正＞ <br> ＜Invalid hash value of downloaded file.＞

#### AGT.3.2.61
* □□□
* ダウンロードしたファイルのハッシュ値が不正な場合はログに記録する。 <br> Log if the hash value of the downloaded file is invalid. <br>  <br> 「Log Message 」シートを参照。 <br> See the 'Log Message' sheet.

#### AGT.3.2.63
* □□□
* ＜遠隔操作の実行失敗＞処理を実行する。(AGT3.1.90) <br> Execute the ＜Failed to execute remote control＞ process.

#### AGT.3.2.70
* ＜ファイルダウンロード完了通知 Web API 失敗＞ <br> ＜File download completion notification Web API failure＞

#### AGT.3.2.71
* □□□
* 「ファイルダウンロード完了通知 Web API」が失敗した場合はログに記録する。 <br> Log if file download completion notification Web API fails. <br>  <br> 「Log Message 」シートを参照。 <br> See the 'Log Message' sheet.

#### AGT.3.2.80
* ＜ダウンロードしたファイルの遠隔操作処理に成功＞ <br> ＜Successful remote processing of downloaded files＞

#### AGT.3.2.81
* □□□
* ＜遠隔操作の実行成功＞処理を実行する。(AGT.3.1.80) <br> Execute the ＜Successful execution of remote control＞ process.

#### AGT.3.2.90
* ＜ダウンロードしたファイルの遠隔操作処理に失敗＞ <br> ＜Remote processing of downloaded files fails＞

#### AGT.3.2.91
* □□□
* デバイスの「F/Wアップデート（2010）」に失敗した場合はログに記録する。 <br> Log if the device F/W failes to update. <br>  <br> 「Log Message 」シートを参照。 <br> See the 'Log Message' sheet.

##### AGT.3.2.91.1
* □□□
* 「設定データJSON」ファイルによるデバイスの設定変更に失敗した場合はログに記録する。 <br> Log any failed attempts to change device settings using the "Configuration Data JSON" file. <br>  <br> 「Log Message 」シートを参照。 <br> See the 'Log Message' sheet.

##### AGT.3.2.91.2
* □□□
* 「設定情報」ファイル（*.bin or *.cfg）によるデバイスの設定復元に失敗した場合はログを記録する。 <br> Log any failure to restore device configuration according to the "Configuration Information" file (*.bin or *.cfg). <br>  <br> 「Log Message 」シートを参照。 <br> See the 'Log Message' sheet.

#### AGT.3.2.92
* □□□
* ＜遠隔操作の実行失敗＞処理を実行する。(AGT3.1.90) <br> Execute the ＜Failed to execute remote control＞ process.

### AGT.3.3
* 要求 <br> request
* サーバーへのファイルアップロードが必要な遠隔操作リクエストを処理できること。 <br> Functions requested via remote operation (including file upload) shall be executable.

- 理由 | ログファイルのアップロードや設定ファイルのアップロードなど、サーバーへのファイルアップロードが必要な遠隔操作を実行したい。 <br> I want to perform remote operations that require file uploads to the server, such as log file uploads and configuration file uploads.
- 説明
#### AGT.3.3.0
* ＜遠隔操作情報の受信と解析＞ <br> <Receiving and Analyzing Remote Control Information>

#### AGT.3.3.1
* □□□
* サーバーから受信した遠隔操作情報で、対象の「遠隔操作ID」か否かチェックすること。 <br> Remote operation information received from the server shall be checked to see if it is the target "remote operation ID" or not. <br>  <br> 対象の遠隔操作ID <br> Target Remote Operation ID <br> 　・ログのアップロード（4020） <br> 　　Upload log <br> 　・設定ファイルのアップロード（4030） <br> 　　Upload configuration file <br> 　・接続クライアントファイルのアップロード（4040） <br> 　　Upload connection client file <br> 　・設定取得（5060） <br> 　　Get Settings <br>  <br> 対象の遠隔操作IDだった場合、各遠隔操作IDに応じた処理を実行すること。 <br> If it is a target remote operation ID, the process shall be executed according to each remote operation ID. <br>  <br> アップロードするファイルの詳細に関しては「Upload,Download Files」シートを参照。 <br> See the "Upload,Download Files" sheet for details on files to be uploaded.

#### AGT.3.3.2
* □□□
* 遠隔操作IDが「ログのアップロード（4020）」の場合、デバイスのRAMログから、アップロード用の「ログファイル」を作成する。 <br> When the remote operation ID is "Upload Log (4020)", a "log file" is created for upload from the device's RAM log. <br>  <br> 注：デバイス側のログメッセージが0件の場合、ログファイルの作成は失敗とし、＜ファイルのアップロード失敗＞を実行すること。 <br> Note: If there are zero log messages on the device side, the log file creation shall fail and <File Upload Failure> shall be executed. <br>  <br> 「遠隔操作許可」が「有効」且つ、「ログファイルアップロード許可」が「有効」の場合のみ実行すること。 <br> This function is executed only when "Remote control permission" is "Enabled" and "Log file upload permission" is "Enabled". <br> 「無効」の場合は実行しない。 <br> If "Disabled", it will not be executed.

#### AGT.3.3.3
* □□□
* 遠隔操作IDが「設定ファイルのアップロード（4030）」の場合、アップロード用の「設定ファイル」を作成する。 <br> If the remote operation ID is "Configuration File Upload (4030)", create a "configuration file" for upload. <br>  <br> 「遠隔操作許可」が「有効」且つ、「設定ファイルアップロード許可」が「有効」の場合のみ実行すること。 <br> This function is executed only when "Remote control permission" is "Enabled" and "Log file upload permission" is "Enabled". <br> 「無効」の場合は実行しない。 <br> If "Disabled", it will not be executed.

#### AGT.3.3.4
* □□□
* 遠隔操作IDが「接続クライアントファイルのアップロード（4040）」の場合、アップロード用の「接続クライアントファイル」を作成する。 <br> If the remote operation ID is "Upload Connection Client File (4040)", create a "connection client file" for upload. <br>  <br> 「遠隔操作許可」が「有効」且つ、「接続クライアントファイルアップロード許可」が「有効」の場合のみ実行する。 <br> This function is executed only when "Remote control permission" is "Enabled" and "Log file upload permission" is "Enabled". <br> 「無効」の場合は実行しない。 <br> If "Disabled", it will not be executed.

#### AGT.3.3.5
* □□□
* 遠隔操作IDが「設定取得（5060）」の場合、現在の設定値を基にアップロード用の「設定データJSONファイル」を作成する。 <br> When the remote operation ID is "Setting acquisition (5060)", a "setting data JSON file" is created for upload based on the current setting values. <br>  <br> 「遠隔操作許可」が「有効」の場合のみ実行する。 <br> This function is executed only when "Remote control permission" is "Enabled". <br> 「無効」の場合は実行しない。 <br> If "Disabled", it will not be executed.

#### AGT.3.3.6
* □□□
* アップロードするファイルの作成に成功した場合、アドミリンクサービスへアップロードする。 <br> After device Log file creation complete, upload it to the AdminLink server. <br>  <br> ファイルアップロード処理は以下のフローに従うこと。 <br> 「EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow).xlsx」の <br> 「8.File upload flow」 <br> The file upload process is followed by the sheet 「8.File upload flow」 on 「EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow).xlsx」.

#### AGT.3.3.7
* □□□
* ファイルをアップロードするために、「ファイルアップロード用URL取得API」をコールして、アップロード用のURLを取得する。 <br> To upload a file, call "Get URL for File Upload API" to get the URL for uploading.

#### AGT.3.3.10
* ＜アップロードURLの取得に成功＞ <br> ＜Successfully retrieved upload URL.＞

#### AGT.3.3.11
* □□□
* 取得したURLへファイルをアップロードする。 <br> Upload the file to the URL obtained.

#### AGT.3.3.20
* ＜アップロードURLの取得に失敗＞ <br> ＜Failed to retrieve upload URL.＞

#### AGT.3.3.21
* □□□
* ファイルアップロード用URL取得 Web APIが失敗した場合、ログに記録する。 <br> Log if the Web API to retrieve File Upload URL fails. <br>  <br> 「Log Message 」シートを参照。 <br> See the 'Log Message' sheet.

#### AGT.3.3.22
* □□□
* ＜遠隔操作の実行失敗＞処理を実行する。(AGT3.1.90) <br> Execute the ＜Failed to execute remote control＞ process.

#### AGT.3.3.30
* ＜ファイルのアップロード成功＞ <br> ＜Successful upload file＞

#### AGT.3.3.31
* □□□
* アップロード完了後、「ファイルアップロード完了通知API」をコールしてアドミリンクサーバーへアップロードの完了を通知する。 <br> After the upload is complete, call the file upload completion notification Web API to notify the Admirink server of the completion of the upload. <br>  <br> 遠隔操作リクエストによってファイルのアップロードを実行した場合は、自動アップロードフラグ（auto_flg）を 0 （手動）に設定すること。 <br> When a file upload is executed by remote control request, the "automatic upload flag (auto_flg)" included in the "File upload completion notification Web API" parameter must be set to 0 (manual).

#### AGT.3.3.40
* ＜ファイルのアップロード失敗＞ <br> ＜Failed to upload＞

#### AGT.3.3.41
* □□□
* ファイルのアップロードに失敗した場合はログに記録する。 <br> Log if file fails to uploaded. <br>  <br> 「Log Message 」シートを参照。 <br> See the 'Log Message' sheet.

#### AGT.3.3.42
* □□□
* ＜遠隔操作の実行失敗＞処理を実行する。(AGT3.1.90) <br> Execute the ＜Failed to execute remote control＞ process.

#### AGT.3.3.50
* ＜ファイルアップロード完了通知API成功＞ <br> ＜File upload completion notification API failure＞

#### AGT.3.3.51
* □□□
* ＜遠隔操作の実行成功＞処理を実行する。(AGT.3.1.80) <br> Execute the ＜Successful execution of remote control＞ process.

#### AGT.3.3.60
* ＜ファイルアップロード完了通知API失敗＞ <br> ＜File upload completion notification Web API failure＞

#### AGT.3.3.61
* □□□
* 「ファイルアップロード完了通知API」 の実行に失敗した場合、ログに記録する。 <br> Log it the execution of the file upload completion notification Web API fails. <br>  <br> 「Log Message 」シートを参照。 <br> See the 'Log Message' sheet.

#### AGT.3.3.62
* □□□
* ＜遠隔操作の実行失敗＞処理を実行する。(AGT3.1.90) <br> Execute the ＜Failed to execute remote control＞ process.

### AGT.3.4
* 要求 <br> request
* 遠隔操作で、「災害モード」の設定を変更できること。 <br> The "Emergency mode" setting must be able to be changed by remote control.

- 理由 | 遠隔地からAPを災害モードに切り替えたい。 <br> I want to switch the AP to Emergency mode from a remote location.
- 説明 | 遠隔操作リクエスト（5090）を受信し、災害モードの有効/無効を切り替える。 <br> Receive remote control request (5090) to enable/disable Emergency mode.
#### AGT.3.4.0
* ＜遠隔操作情報の受信と解析＞ <br> <Receiving and Analyzing Remote Control Information>

#### AGT.3.4.1
* □□□
* サーバーから受信した遠隔操作情報で、「遠隔操作ID」が「災害モード設定(ID: 5090)」の場合、＜災害モードを設定する＞を実行する。 <br> In the remote operation information received from the server, if the "remote operation ID" is "Emergency mode setting (ID: 5090)", <Set Emergency mode> is executed.

#### AGT.3.4.10
* ＜災害モードを設定する＞ <br> <Setting Disaster Mode>

#### AGT.3.4.11
* □□□
* 「Remote control ID spec list」シートの遠隔操作ID：5090を実行する。 <br> Execute remote control ID: 5090 on the "Remote control ID spec list" sheet.

#### AGT.3.4.20
* ＜災害モードの設定に成功＞ <br> <Successfully set Emergencyr Mode>

#### AGT.3.4.21
* □□□
* 災害モードの設定をデバイスに適用した事をログに記録すること。 <br> The application of the Emergency Mode setting to the device shall be recorded in the log. <br> ※災害モード、利用可能ポートの各設定値を記録すること。 <br> The values of each setting for Emergency Mode and available ports shall be recorded.

#### AGT.3.4.22
* □□□
* ＜遠隔操作の実行成功＞処理を実行する。(AGT.3.1.80) <br> Execute the ＜Successful execution of remote control＞ process.

#### AGT.3.4.23
* □□□
* 設定完了後、デバイスを再起動すること。 <br> The device shall be rebooted after configuration is complete.

#### AGT.3.4.30
* ＜災害モードの設定に失敗＞ <br> <Failed to set Emergency Mode>

#### AGT.3.4.31
* □□□
* 災害モードの設定に失敗した事をログに記録すること。 <br> Failure to set disaster mode should be logged.

#### AGT.3.4.32
* □□□
* ＜遠隔操作の実行失敗＞処理を実行する。(AGT3.1.90) <br> Execute the ＜Failed to execute remote control＞ process.

## AGT.4
* 要求 <br> request
* アドミリンクサーバー側だけでデバイスの登録と設定をできること。 <br> Device registration and configuration shall be completable through operations on the AdminLink server side.

- 理由 | デバイスを設置した際、設置者自身は接続作業のみで、設定作業を不要にしたい。 <br> We want to complete the setup process by simply installing the device on site.
- 説明 | 対象はスイッチとAP <br> Subjects are switches and APs.
### AGT.4.1
* 要求 <br> request
* 自動登録フロー実行判定 <br> Automatic Registration Flow Execution Judgment

- 理由 <br> Reason | ゼロタッチ設定のための自動仮登録の他、従来の登録方法もサポートするため、デバイスの動作開始時にゼロタッチ設定可能な状態か否か、デバイスの状態を判定したい。 <br> To support conventional registration methods as well as automatic temporary registration for zero-touch setting, we would like to determine the device status to determine if the device is ready for zero-touch setting at the start of device operation.
- 説明 <br> Description | デバイスの設定に変更があるか否かを判定し、変更がある場合は自動登録フローを、変更が無い場合は通常起動フローを実行する。 <br> Judges whether or not there is a change in the device settings, and executes the automatic registration flow if there is a change, or the normal startup flow if there is no change.
#### AGT.4.1.0
* ＜出荷時の設定＞ <br> <Shipping Configuration>

#### AGT.4.1.1
* □□□
* 工場出荷時、デバイスは下記の設定であること。 <br> When shipped from the factory, the device shall have the following settings <br>  <br> ・DHCPクライアント機能が有効であること <br> 　DHCP client functionality must be enabled. <br>  <br> ・アドミリンク機能が有効であること <br> 　AdminLink functionality must be enabled. <br>  <br> ・「アドミリンク詳細設定」の「遠隔操作許可」が有効であること <br> 　"Remote Control Permission" in "AdminLink Advanced" must be "Enabled" <br>  <br> ・「MACアドレス」および「レジストコード」が不揮発性メモリ領域に書き込まれていること <br> 　MAC address" and "resist code" shall be written in the non-volatile memory area. <br>  <br> ・NTP/SNTPによる時刻同期が選択されていること（タイムゾーン：UTC+09:00／サマータイム：OFF） <br> 　Time synchronization by NTP/SNTP must be selected (time zone: UTC+09:00 / daylight saving time: OFF)

#### AGT.4.1.10
* ＜デバイス起動（コールドスタート/ホットスタート問わず）時の処理＞ <br> <Processing at device startup (whether cold start or hot start)>

#### AGT.4.1.11
* □□□
* デバイスの電源投入時または再起動時に、通常起動フローを完了して以下の条件をすべて満たした場合、＜設定変更の有無判定＞を実行する。 <br> When the device is powered on or restarted, if the normal startup flow is completed and all of the following conditions are met, <Configuration Change Existence Judgment> is executed. <br>  <br> ・デバイスが、NTP/SNTPによる時刻同期を完了していること。 <br> 　The device must have completed time synchronization via NTP/SNTP. <br>  <br> ・デバイスが、アドミリンクサーバーとの通信が可能な状態であること。 <br> 　The device must be able to communicate with the AdminLink server <br>  <br> ・デバイスが、「設定変更」(遠隔操作ID：5070)および「設定復元」（遠隔操作ID：5080）リクエストを処理可能な状態であること。 <br> 　The device shall be ready to process "Change Settings" (Remote ID: 5070) and "Restore Settings" (Remote ID: 5080) requests.

#### AGT.4.1.20
* ＜設定変更の有無判定＞ <br> <Determination of whether or not settings have been changed>

#### AGT.4.1.21
* □□□
* 「管理者パスワード」がデフォルトから変わっていない場合は、「自動登録フロー」を実行すること。 <br> If the "Administrator Password" has not been changed from the default, the "Automatic Registration Flow" shall be executed.

#### AGT.4.1.22
* □□□
* 差異がある場合は、処理を終了。 <br> If there is a difference in settings, the process is terminated.

### AGT.4.2
* 要求 <br> request
* 自動登録フロー <br> Automatic Registration Flow

- 理由 <br> Reason | レジストコードを使ってデバイスをサーバーへ仮登録したい。 <br> I want to temporary register a device to the server using a regist code.
- 説明 <br> Description | デバイスが保持しているレジストコードをパラメータにセットして「デバイス登録API」をコールし、デバイスをサーバーへ仮登録する。通信エラーが発生して仮登録に失敗した場合は、リトライする。 <br>  <br> Set the resist code held by the device as a parameter and call the "Device Registration API" to temporary register the device to the server. If a communication error occurs and temporary registration fails, retry.
#### AGT.4.2.0
* ＜デバイス登録APIをコールする＞ <br> <Calling Device Registration API>

#### AGT.4.2.1
* □□□
* デバイスIDを新規に生成し、RAM上に保持すること。 <br> A new device ID shall be generated and retained in RAM. <br>  <br> ※デバイスIDは、UUID Ver4 形式 とする（AGT.1.4.2）。 <br> 　The device ID shall be in UUID Ver4 format (AGT.1.4.2). <br>  <br> ※生成したデバイスIDは、この時点では不揮発性メモリに書き込まないこと。 <br> 　The generated device ID should NOT be written to non-volatile memory at this time.

#### AGT.4.2.2
* □□□
* 生成したデバイスIDと、デバイスが保持しているレジストコードと、MACアドレスをパラメーターに指定して、「デバイス登録API」をコールすること。 <br> The "Device Registration API" shall be called with the generated device ID, the resist code held by the device, and the MAC address as parameters. <br>  <br> ※「デバイス登録API」の詳細については、「WebAPI仕様書」を参照すること。 <br> 　For details on the "Device Registration API," refer to the "WebAPI Specification. <br>  <br> リクエストボディには下記のキーを含める事。 <br> The request body must include the following keys <br> ・製品カテゴリ（prdct） <br> ・レジストコード（regist_cd） <br> ・遠隔操作許可（remote_flg）：「許可する（1）」をセットすること。 <br> ・プロキシ設定（proxy_flg）：「無効（0)」をセットすること。 <br> ・デバイスID（dev_id） <br> ・製品シリーズ名（prdct_series） <br> ・製品型番（prdct_name） <br> ・製品型番識別文字列（prdct_id） <br> ・代表IPアドレス（ip_adr） <br> ・代表MACアドレス（mac_adr） <br> ・管理ソフトニーモニック（ms_mnemonic） <br> ・管理ソフトバージョン（ms_ver） <br> ・エージェントニーモニック（agt_mnemonic） <br> ・エージェントバージョン（agt_ver） <br>  <br> ※各キーの値（例：製品カテゴリ、製品シリーズ名など）については、 <br> 別紙「AdminLink_DeviceRegistrationAPI_Parameters(APSW)」を参照すること。 <br> For the value of each key (e.g., product category, product series name, etc.), <br> Refer to the Appendix "AdminLink_DeviceRegistrationAPI_Parameters(APSW)".

#### AGT.4.2.3
* □□□
* 「デバイス登録API」のレスポンスステータスを取得し、「ステータスコード」に応じた処理を実行すること。 <br> The response status of the "Device Registration API" shall be obtained and processing shall be executed according to the "Status Code".

#### AGT.4.2.10
* ＜デバイス登録APIのステータスコードが201（Created）の場合＞ <br> <Device Registration API status code is 201 (Created)>

#### AGT.4.2.11
* □□□
* 「デバイス登録API」が成功したことをログへ記録すること。 <br> The success of the "Device Registration API" shall be recorded in the log. <br> あわせて、レスポンスボディで返却された下記パラメータの値もそのログへ記録すること。 <br> In addition, the values of the following parameters returned in the response body shall also be recorded in the log. <br> 　・デバイスID変更フラグ（dev_id_changed） <br> 　・情報送信タイミング計算用秒数（agt_upload_sec） <br> 　・日次処理実行時刻計算用秒数（agt_daily_sec） <br> 　・仮登録有効期限日時（tmp_reg_expiry） (If included in the response body.)

#### AGT.4.2.12
* □□□
* レスポンスボディで返却されたパラメータの値をRAM上に保持すること。 <br> The values of parameters returned in the response body shall be retained in RAM. <br> ※この処理では不揮発性メモリに書き込まないこと。 <br> This process shall NOT write to non-volatile memory. <br>  <br> RAM上に保持するキーは以下の通り。 <br> The keys to be held in RAM are as follows <br> 　・デバイスID（dev_id） <br> 　・日次処理実行時刻計算用秒数（agt_daily_sec） <br> 　・情報送信タイミング計算用秒数（agt_upload_sec） <br> 　・仮登録有効期限日時（tmp_reg_expiry） (If included in the response body.) <br>  <br> ※レスポンスボディに 'tmp_reg_expiry' キーが含まれていない場合は、'tmp_reg_expiry'の値はRAM上に保持しないこと。 <br> NOTE: If the 'tmp_reg_expiry' key is not included in the response body, the 'tmp_reg_expiry' value must NOT be retained in RAM.

#### AGT.4.2.13
* □□□
* レスポンスボディに 'tmp_reg_expiry' キーが含まれている場合には、「ゼロタッチ待機処理（AGT.4.3）」を実行すること。 <br> If the 'tmp_reg_expiry' key is included in the response body, "Zero touch wait processing (AGT.4.3)" shall be executed.

#### AGT.4.2.14
* □□□
* レスポンスボディに 'tmp_reg_expiry' キーが含まれていない場合には、レスポンスボディに含まれている下記の登録情報を、不揮発性メモリに保存して、＜自動登録フローの終了＞（AGT.4.2.40）処理を実行すること。 <br> If the 'tmp_reg_expiry' key is not included in the response body, the following registration information contained in the response body shall be stored in non-volatile memory and the <End of automatic registration flow> (AGT.4.2.40) process shall be executed. <br>  <br> 　・デバイスID（dev_id） <br> 　・日次処理実行時刻計算用秒数（agt_daily_sec） <br> 　・情報送信タイミング計算用秒数（agt_upload_sec） <br>  <br> ※デバイス本体の不揮発性メモリには保存するが、デバイスの設定ファイル（cfg や bin）には書き出さないこと。 <br> Note: These parameters are stored in the non-volatile memory of the device itself, but must not be written out to the device's configuration files (cfg or bin).

#### AGT.4.2.20
* ＜デバイス登録APIのステータスコードが201（Created）以外の場合＞ <br> <Device Registration API status code other than 201 (Created)>

#### AGT.4.2.21
* □□□
* 「デバイス登録API」が失敗したことを、ログに記録すること。 <br> The failure of the "Device Registration API" shall be logged.

#### AGT.4.2.22
* □□□
* ＜自動登録フローの終了＞（AGT.4.2.40）処理を実行すること。 <br> <Terminate the automatic registration flow>（AGT.4.2.40） process shall be executed.

#### AGT.4.2.30
* ＜デバイス登録APIのステータスコードを取得できなかった場合（WebAPIサーバーからの応答なし）＞ <br> <Failure to obtain device registration API status code (no response from WebAPI server)>

#### AGT.4.2.31
* □□□
* 「デバイス登録API」のレスポンスを得られなかったことをログへ記録すること。 <br> The failure to obtain a response from the "Device Registration API" shall be recorded in the log. <br> 初回のみログへ記録し、リトライによる実行の場合はログに記録しないこと。 <br> Only the first time shall be recorded in the log, and execution by retry shall not be recorded in the log.

#### AGT.4.2.32
* □□□
* 10秒間待機し、＜設定変更の有無判定＞（AGT.4.1.20）からリトライすること。 <br> Wait for 10 seconds, and retry from <Determining whether or not the setting has been changed> (AGT.4.1.20).

#### AGT.4.2.40
* ＜自動登録フローの終了＞ <br> <Terminate the automatic registration flow>

#### AGT.4.2.41
* □□□
* 自動登録フローを終了し、AGT.2.1.0 ＜デバイス起動時にエージェント機能を開始する＞ <br> から処理を継続すること。 <br> The automatic registration flow shall be terminated and processing shall be continued from AGT.2.1.0 <Start agent function at device startup>.

### AGT.4.3
* 要求 <br> request
* ゼロタッチ待機処理 <br> Zero touch standby process

- 理由 <br> Reason | サーバーからの遠隔操作で、デバイスの設定を変更したい。 <br> I want to change device settings remotely from the server.
- 説明 <br> Description | 遠隔操作の受付を開始し、遠隔操作による設定変更リクエストを受信した時、デバイスの設定を変更する。 <br> Starts accepting remote control and changes device settings when a remote control configuration change request is received.
#### AGT.4.3.0
* ＜遠隔操作受付開始＞ <br> <Start of Remote Operation Acceptance>

#### AGT.4.3.1
* □□□
* 遠隔操作受信の常駐処理を開始する（AGT.3.1.1）こと。 <br> To start the resident process of remote control reception (AGT.3.1.1). <br>  <br> 遠隔操作受信の詳細については、 <br> 「EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow).xlsx」の「7.Remote control reception flow」シートを参照すること。 <br> For details on remote control reception, <br> Refer to the "7. Remote control reception flow" sheet in "EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow).xlsx".

#### AGT.4.3.10
* ＜遠隔操作受付開始の成功＞ <br> <Successful start of remote acceptance>

#### AGT.4.3.11
* □□□
* 遠隔操作受付開始に成功した事をログへ記録する（AGT.3.1.11）こと。 <br> The successful start of remote operation reception shall be recorded in the log (AGT.3.1.11).

#### AGT.4.3.12
* □□□
* サーバーからの遠隔操作リクエストを受信した場合は、＜遠隔操作の受信＞（AGT.4.3.60）を実行すること。 <br> When a remote control request is received from the server, <Receive Remote Control> (AGT.4.3.60) shall be executed.

#### AGT.4.3.13
* □□□
* ＜設定変更の有無判定＞と＜仮登録有効期限の判定＞を10秒間隔で実行する。 <br> ＜Execute "Judgment as to whether or not the setting has been changed" and "Judgment as to the expiration date of temporary registration" at 10 second intervals.

#### AGT.4.3.20
* ＜遠隔操作受付開始の失敗＞ <br> <Failure to start remote operation reception>

#### AGT.4.3.21
* □□□
* 遠隔操作受付開始に失敗した場合、初回のみログに記録し、リトライで失敗した場合はログに記録しないこと。 <br> If a failure to start remote operation reception occurs, it shall be logged only for the first time, and shall not be logged if a failure occurs in a retry.

#### AGT.4.3.22
* □□□
* RAM上に 'tmp_reg_expiry' の値を保持しており、且つ、現在日時が「仮登録有効期限日時（tmp_reg_expiry）」を超えている場合、ログを記録し、＜ゼロタッチ待機処理終了＞を実行すること。 <br> If the 'tmp_reg_expiry' value is held in RAM and the current date/time exceeds the 'temporary registration expiration date/time (tmp_reg_expiry)', logging and <Zero touch wait process end> must be executed.

#### AGT.4.3.23
* □□□
* RAM上に 'tmp_reg_expiry' の値を保持していない、または現在日時が「仮登録有効期限日時（tmp_reg_expiry）」を超えていない場合は、10秒間待機した後、＜遠隔操作受付開始＞からリトライすること。 <br> If the 'tmp_reg_expiry' value is not kept in RAM, or the current date/time does not exceed the 'temporary registration expiration date/time (tmp_reg_expiry)', it must wait for 10 seconds and then retry from <Start remote operation reception>.

#### AGT.4.3.30
* ＜設定変更の有無判定＞ <br> <Determination of whether or not settings have been changed>

#### AGT.4.3.31
* □□□
* 「管理者パスワード」がデフォルトから変わっていない場合は、「自動登録フロー」を実行すること。 <br> If the "Administrator Password" has not been changed from the default, the "Automatic Registration Flow" shall be executed. <br>  <br> 遠隔操作受付可能な状態を継続すること。 <br> The AdminLink function shall remain available for remote operation reception.

#### AGT.4.3.32
* □□□
* 設定に変更があった場合は処理を停止し、＜ゼロタッチ待機処理終了＞を実行すること。 <br> When there is a change in the setting, the process shall be stopped and <Zero touch standby process end> shall be executed.

#### AGT.4.3.40
* ＜仮登録有効期限の判定＞ <br> <Determination of temporary registration expiration date>

#### AGT.4.3.41
* □□□
* RAM上に 'tmp_reg_expiry' の値を保持しており、現在日時が「仮登録有効期限日時（tmp_reg_expiry）」を超えている場合、ログを記録し、＜ゼロタッチ待機処理終了＞を実行すること。 <br> If the value of 'tmp_reg_expiry' is maintained in RAM and the current date/time exceeds the 'temporary registration expiration date/time (tmp_reg_expiry)', logging must be performed and <Zero touch wait process end> must be executed.

#### AGT.4.3.42
* □□□
* RAM上に 'tmp_reg_expiry' の値を保持していない、または現在日時が「仮登録有効期限日時（tmp_reg_expiry）」を超えていない場合、遠隔操作受付可能な状態を継続すること。 <br> If the 'tmp_reg_expiry' value is NOT kept in RAM or the current date/time does NOT exceed the 'temporary registration expiration date/time (tmp_reg_expiry)', the system must remain ready to accept remote operations.

#### AGT.4.3.50
* ＜遠隔操作受付の切断を検知＞ <br> <Detect that acceptance of remote-control requests has been disconnected.>

#### AGT.4.3.51
* □□□
* 遠隔操作受付の切断を検知した事を、ログに記録すること。 <br> When a disconnection of the communication channel for remote-control reception is detected, the event shall be recorded in the log.

#### AGT.4.3.52
* □□□
* 10秒間待機した後、＜仮登録有効期限の判定＞から再接続をリトライすること。 <br> After waiting for 10 seconds, retry to reconnect from <Temporary Registration Expiration Date Determination>.

#### AGT.4.3.60
* ＜遠隔操作の受信＞ <br> <Remote Receiving>

#### AGT.4.3.61
* □□□
* 以下の遠隔操作のリクエストを受信した場合、受信した遠隔操作IDで示される処理を実行すること。 <br> When the following remote operation requests are received, the process indicated by the received remote operation ID shall be executed. <br>  <br> 　・設定変更(遠隔操作ID：5070)　（AGT.3.2.1） <br> 　　Change Settings <br>  <br> 　・設定復元(遠隔操作ID：5080)　（AGT.3.2.1） <br> 　　Restore Settings

#### AGT.4.3.62
* □□□
* 遠隔操作ID：5070、5080 以外の場合は、＜遠隔操作の実行失敗＞を実行すること。 <br> Remote operation ID: If other than 5070 or 5080, <Remote operation execution failure> shall be executed.

#### AGT.4.3.70
* ＜遠隔操作の実行成功＞ <br> <Successful execution of remote control>

#### AGT.4.3.71
* □□□
* 遠隔操作の処理に成功した場合、＜アドミリンク本登録処理＞を実行すること。 <br> If the remote control process is successful, <AdminLink Full Registration Process> shall be executed.

#### AGT.4.3.80
* ＜遠隔操作の実行失敗＞ <br> <Failure to execute remote control>

#### AGT.4.3.81
* □□□
* ＜遠隔操作の実行失敗＞処理を実行する。(AGT3.1.90) <br> Execute the ＜Failed to execute remote control＞ process.

#### AGT.4.3.82
* □□□
* 遠隔操作受付可能な状態を継続すること。 <br> Remote operation acceptance must continue to be available.

#### AGT.4.3.90
* ＜アドミリンク本登録処理＞ <br> <AdminLink Full Registration Process>

#### AGT.4.3.91
* □□□
* RAM上に保持している下記の登録情報を不揮発性メモリに保存し、登録状態を「登録済み」にすること。 <br> The following registration information held in RAM shall be stored in non-volatile memory and the registration status shall be set to "registered". <br>  <br> 　・デバイスID（dev_id） <br> 　・日次処理実行時刻計算用秒数（agt_daily_sec） <br> 　・情報送信タイミング計算用秒数（agt_upload_sec） <br>  <br> ※デバイス本体の不揮発性メモリには保存するが、デバイスの設定ファイル（cfg や bin）には書き出さないこと。 <br> Note: These parameters are stored in the non-volatile memory of the device itself, but must not be written out to the device's configuration files (cfg or bin).

#### AGT.4.3.92
* □□□
* ＜ゼロタッチ待機処理終了＞を実行すること。 <br> ＜The "Zero touch standby process end" shall be executed.

#### AGT.4.3.93
* □□□
* 遠隔操作受信の常駐処理は継続すること。 <br> Resident processing of remote control reception must continue.

#### AGT.4.3.94
* □□□
* デバイスの本登録が完了したことをログに記録すること。 <br> Log the completion of this registration of the device.

#### AGT.4.3.95
* □□□
* 下記のイベントJSONをアドミリンクサーバーへ送信すること。 <br> The following event JSON shall be sent to the AdminLink server. <br> ・エージェント初期化（アクションID：5060） <br> 　Agent initialization (Action ID: 5060)

#### AGT.4.3.96
* □□□
* デバイスを再起動すること。 <br> Device should be rebooted.

#### AGT.4.3.100
* ＜ゼロタッチ待機処理終了＞ <br> <Zero touch standby process end>

#### AGT.4.3.101
* □□□
* RAM上に「仮登録有効期限日時（tmp_reg_expiry）」が保持されている場合は、これを破棄すること。 <br> If a "temporary registration expiration date/time (tmp_reg_expiry)" is retained in RAM, it shall be destroyed.

#### AGT.4.3.102
* □□□
* デバイスが未登録（それは不揮発性メモリにデバイスIDが保存されていない事を意味する）の場合、遠隔操作受信の常駐処理を停止すること。 <br> If the device is unregistered (which means that the device ID is not stored in non-volatile memory), the resident process of remote control reception must be stopped.

#### AGT.4.3.103
* □□□
* ゼロタッチ待機処理を終了し、AGT.2.1.0 ＜デバイス起動時にエージェント機能を開始する＞ <br> から処理を継続すること。 <br> The zero-touch standby process shall be terminated and the process shall be continued from AGT.2.1.0 <Start agent function at device startup>.

