import CommonConstants from'./CommonConstants'
import ItemData from './ItemData'
import DataModel from './DataModel'
import router from'@ohos.router'
@Entry
@Component
struct MySetting{

  @State
  account:number=111
  onPageShow(){
    let acc=router.getParams() as Record<string,number>
    if(acc){
      this.account=acc['sendMsg']
    }
  }
  //构建设置单元格函数，接受一个ItemData类型的item作为参数
  @Builder
  settingCell(item:ItemData){
    Row(){
      Row({space:CommonConstants.COMMON_SPACE}){
        Image(item.img)
          .width($r('app.float.setting_size'))
          .height($r('app.float.setting_size'))
        Text(item.title)
          .fontSize($r('app.float.normal_text_size'))
      }
      if(item.others == null){
        Image($r('app.media.right_grey'))
          .width($r('app.float.setting_jump_width'))
          .height($r('app.float.setting_jump_height'))
      }else{
        Toggle({type:ToggleType.Switch.isOn:false})//显示一个开关组件
      }
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width(CommonConstants.FULL_PARENT)
    .padding({
      left:$r('app.float.setting_settingCell_left')
      right:$r('app.float.setting_settingCell_right')
    })
  }

  build(){
    Scroll(){
      Column(space:CoCommonConstants.COMMON_SPACE){
        Text($('app.string.mainPage_tabTitles_mine'))
          .fontWeight(FontWeight.Medium)
          .fontSize($r('app.floating.page_title_text_size'))
          .margin({top:$r('app.floating.mainPage_tabTitles_margin')})
          .padding({left:$r('app.floating.mainPage_tabTitles_padding')})
      }
      .width(CommonConstants.FULL_PARENT)
        .alignItems(HorizontalAlign.Start)

      Row(){
        Image($r('app.media.account'))//显示账户图片
          .width($r('app.float.setting_account_width'))
          .height($r('app.float.setting_account_size'))
        Column(){
          Text($r('app.string.setting_account_name'))//显示账户名称
            .fontSize($r('app.float.setting_account_fontSize'))//设置字号
          Text(this.account.toString())//显示账号
            .fontSize($r('app.float.little_text_size'))
            .margin({top:$r('app.float.setting_name_margin')})
        }
        .alignItems(HorizontalAlign.Start)//设置子项再交叉轴上的对齐方式为开始对齐
        .margin({top:$r('app.float.setting_name_margin')})//设置外边距
      }
      .margin({top:$r('app.float.setting_account_margin')})//设置外边距
      .alignItems(VerticalAlign.Center)//设置子项再交叉轴上的对齐方式为居中对齐
      .width(CommonConstants.FULL_PARENT)
      .height($r('app.float.setting_account_height'))
      .backgroundColor(Color.White)
      .padding({left:$r('app.float.setting_account_padding')})
      .borderRadius($r('app.float.setting_account_borderRadius'))

      //列表布局组件
      List(){
        ForEach(DataModel.getSettingListData(),(item:ItemData)=>{
          ListItem(){
            this.settingCell(item)
          }
          .height($r('app.float.setting_list_height'))
        })
      }
      .backgroundColor(Color.White)
      .width(CommonConstants.FULL_PARENT)
      .height(CommonConstants.SET_LIST_WIDTH)//设置高度
      .divider({
        strokeWidth:$r('app.float.setting_list_strokeWidth'),
        color:Color.Gray,
        startMargin:$r('app.float.setting_list_startMargin'),
        endMargin:$r('app.float.setting_list_endMargin')
      })
      .borderRadius($r('app.float.setting_list_borderRadius'))
      .padding({top:$r('app.float.setting_list_padding'),botttom:$r('app.float.setting_list_padding')})

      Blank()

      //退出按钮的布局
      Button($r('app.string.setting_button'),{type:ButtonType.Capsule})//创建一个按钮
        .width(CommonConstants.BUTTON_WIDTH)
        .height($r('app.float.login_button_height'))
        .fontSize($r('app.float.normal_text_size'))
        .fontColor($r('app.color.setting_button_backgroundColor'))
        .fontWeight(FontWeight.Medium)//字体权重
        .backgroundColor($r('app.color.setting_button_backgroundColor'))
        .margin({bottom:$r('app.floa t.setting_button_bottom')})

    }
    .height(CommonConstants.FULL_PARENT)
  }
}