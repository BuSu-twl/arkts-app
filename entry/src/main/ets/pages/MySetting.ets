import CommonConstants from'./CommonConstants'
import ItemData from './ItemData'
import DataModel from './DataModel'

@Entry
@Component
struct MySetting{

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
          .width($r('app.floating.setting_account_width'))
      }
    }
  }
}