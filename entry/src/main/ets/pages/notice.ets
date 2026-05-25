import router from '@ohos.router';

interface NoticeItem {
  id: number;
  title: string;
  content: string;
  time: string;
  type: 'system' | 'activity' | 'order';
  isRead: boolean;
}

@Entry
@Component
struct NoticePage {
  @State notices: NoticeItem[] = [
    {
      id: 1,
      title: '系统维护通知',
      content: '尊敬的用户，我们将于今晚23:00-次日02:00进行系统维护升级，期间部分功能可能无法正常使用，请您提前做好准备。',
      time: '2024-01-15 10:30',
      type: 'system',
      isRead: false
    },
    {
      id: 2,
      title: '新用户优惠活动',
      content: '恭喜您获得新人专享优惠券！满100减20，满200减50，快来选购心仪商品吧！活动时间有限，赶快行动。',
      time: '2024-01-14 15:20',
      type: 'activity',
      isRead: false
    },
    {
      id: 3,
      title: '订单发货通知',
      content: '您的订单已发货，快递单号：SF1234567890，预计2-3天送达，请注意查收。',
      time: '2024-01-13 09:15',
      type: 'order',
      isRead: true
    },
    {
      id: 4,
      title: '春节放假通知',
      content: '尊敬的用户，春节期间（2月10日-2月17日）客服服务时间调整为9:00-18:00，如有紧急问题请联系在线客服。',
      time: '2024-01-12 14:00',
      type: 'system',
      isRead: true
    },
    {
      id: 5,
      title: '会员积分到期提醒',
      content: '您的会员积分将于本月底到期，当前可用积分：2580分，请及时兑换精美礼品或抵扣现金。',
      time: '2024-01-11 11:45',
      type: 'system',
      isRead: false
    },
    {
      id: 6,
      title: '限时秒杀活动',
      content: '明日10:00开启限时秒杀活动，爆款商品低至1折！热门手机、家电、数码产品等你来抢！',
      time: '2024-01-10 16:30',
      type: 'activity',
      isRead: true
    }
  ];

  getNoticeTypeColor(type: string): string {
    switch (type) {
      case 'system':
        return '#4CAF50';
      case 'activity':
        return '#FF5000';
      case 'order':
        return '#2196F3';
      default:
        return '#999999';
    }
  }

  getNoticeTypeText(type: string): string {
    switch (type) {
      case 'system':
        return '系统';
      case 'activity':
        return '活动';
      case 'order':
        return '订单';
      default:
        return '其他';
    }
  }

  markAsRead(id: number) {
    const notice = this.notices.find(item => item.id === id);
    if (notice) {
      notice.isRead = true;
    }
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(16)
          .fontColor('#FF5000')
          .onClick(() => {
            router.back();
          })

        Text('消息通知')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text('全部已读')
          .fontSize(14)
          .fontColor('#FF5000')
          .onClick(() => {
            this.notices.forEach(notice => {
              notice.isRead = true;
            });
          })
      }
      .width('100%')
      .height(50)
      .padding({ left: 15, right: 15 })
      .backgroundColor('#FFFFFF')

      List({ space: 10 }) {
        ForEach(this.notices, (notice: NoticeItem) => {
          ListItem() {
            Column() {
              Row() {
                Text(this.getNoticeTypeText(notice.type))
                  .fontSize(12)
                  .fontColor(Color.White)
                  .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                  .borderRadius(4)
                  .backgroundColor(this.getNoticeTypeColor(notice.type))

                Text(notice.title)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(notice.isRead ? '#666666' : '#333333')
                  .layoutWeight(1)
                  .margin({ left: 10 })

                if (!notice.isRead) {
                  Circle()
                    .width(8)
                    .height(8)
                    .fill('#FF5000')
                }
              }
              .width('100%')
              .alignItems(VerticalAlign.Center)

              Text(notice.content)
                .fontSize(14)
                .fontColor('#999999')
                .width('100%')
                .margin({ top: 8 })
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

              Text(notice.time)
                .fontSize(12)
                .fontColor('#CCCCCC')
                .width('100%')
                .margin({ top: 8 })
            }
            .width('100%')
            .padding(15)
            .backgroundColor(notice.isRead ? '#FFFFFF' : '#FFF9F5')
            .borderRadius(8)
            .onClick(() => {
              this.markAsRead(notice.id);
            })
          }
        }, (notice: NoticeItem) => notice.id.toString())
      }
      .width('100%')
      .layoutWeight(1)
      .padding(15)
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
