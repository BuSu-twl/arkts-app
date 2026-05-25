import router from '@ohos.router';

@Entry
@Component
struct PrivacyPolicyPage {
  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(16)
          .fontColor('#FF5000')
          .onClick(() => {
            router.pushUrl({ url: '/pages/MySetting' });
          })

        Text('隐私协议')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .height(50)
      .padding({ left: 15, right: 15 })
      .backgroundColor('#FFFFFF')

      Scroll() {
        Column({ space: 20 }) {
          Column({ space: 10 }) {
            Text('隐私政策')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .width('100%')
              .margin({left:20})

            Text('生效日期：2026年5月17日')
              .fontSize(14)
              .fontColor('#999999')
              .width('100%')
              .margin({left:20})
          }
          .width('100%')
          .padding({ bottom: 10 })

          Column({ space: 15 }) {
            Text('引言')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .width('100%')

            Text('欢迎您使用我们的应用程序。我们非常重视您的隐私保护和个人信息安全。本隐私政策将向您说明我们如何收集、使用、存储和分享您的个人信息，以及您享有的相关权利。请您在使用我们的服务前仔细阅读并理解本隐私政策。')
              .fontSize(15)
              .fontColor('#666666')
              .lineHeight(24)
              .width('100%')
          }
          .width('100%')
          .padding({ left: 15, right: 15 })

          Column({ space: 15 }) {
            Text('一、信息收集')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .width('100%')

            Text('我们可能收集以下类型的信息：')
              .fontSize(15)
              .fontColor('#666666')
              .width('100%')

            Column({ space: 10 }) {
              Text('1.1 您主动提供的信息')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .width('100%')

              Text('• 注册账号时提供的手机号码、昵称等基本信息')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')

              Text('• 购物时提供的收货地址、联系方式等')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')

              Text('• 支付时的相关交易信息')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')

              Text('• 客服沟通时的记录信息')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')
            }
            .width('100%')
            .padding({ left: 10 })

            Column({ space: 10 }) {
              Text('1.2 自动收集的信息')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .width('100%')

              Text('• 设备信息：设备型号、操作系统版本、唯一设备标识符等')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')

              Text('• 日志信息：访问时间、浏览记录、搜索记录等')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')

              Text('• 位置信息：在您授权的情况下获取您的位置信息')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')

              Text('• Cookie信息：用于改善用户体验和提供个性化服务')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')
            }
            .width('100%')
            .padding({ left: 10 })
          }
          .width('100%')
          .padding({ left: 15, right: 15 })

          Column({ space: 15 }) {
            Text('二、信息使用')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .width('100%')

            Text('我们使用收集的信息用于以下目的：')
              .fontSize(15)
              .fontColor('#666666')
              .width('100%')

            Column({ space: 10 }) {
              Text('• 为您提供商品购买、订单处理、配送等服务')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')

              Text('• 处理您的退款、退换货请求')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')

              Text('• 向您发送订单状态更新、物流信息等通知')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')

              Text('• 提供客户服务和技术支持')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')

              Text('• 改进我们的产品和服务质量')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')

              Text('• 防范欺诈行为，保障交易安全')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')

              Text('• 根据您的偏好向您推荐商品和服务')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')

              Text('• 遵守法律法规要求')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')
            }
            .width('100%')
            .padding({ left: 10 })
          }
          .width('100%')
          .padding({ left: 15, right: 15 })

          Column({ space: 15 }) {
            Text('三、信息共享与披露')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .width('100%')

            Text('我们不会向第三方出售您的个人信息。但在以下情况下，我们可能会共享您的信息：')
              .fontSize(15)
              .fontColor('#666666')
              .width('100%')

            Column({ space: 10 }) {
              Text('• 与物流公司、支付机构等合作伙伴共享必要信息以完成订单')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')

              Text('• 根据法律法规要求或政府部门要求提供信息')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')

              Text('• 为保护我们的合法权益、防止欺诈行为')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')

              Text('• 在获得您明确同意的情况下')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')

              Text('• 与我们的关联公司共享必要的用户数据')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')
            }
            .width('100%')
            .padding({ left: 10 })
          }
          .width('100%')
          .padding({ left: 15, right: 15 })

          Column({ space: 15 }) {
            Text('四、信息存储与保护')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .width('100%')

            Text('我们采取以下措施保护您的个人信息：')
              .fontSize(15)
              .fontColor('#666666')
              .width('100%')

            Column({ space: 10 }) {
              Text('• 使用SSL加密技术保护数据传输过程中的安全')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')

              Text('• 采用加密存储技术保护您的个人信息')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')

              Text('• 建立严格的数据访问权限控制机制')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')

              Text('• 定期进行安全审计和风险评估')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')

              Text('• 对员工进行隐私保护培训')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')

              Text('• 您的个人信息将存储在安全的服务器上，保存期限为实现收集目的所必需的时间')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')
            }
            .width('100%')
            .padding({ left: 10 })
          }
          .width('100%')
          .padding({ left: 15, right: 15 })

          Column({ space: 15 }) {
            Text('五、您的权利')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .width('100%')

            Text('您享有以下权利：')
              .fontSize(15)
              .fontColor('#666666')
              .width('100%')

            Column({ space: 10 }) {
              Text('• 查询权：您可以查询我们持有的您的个人信息')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')

              Text('• 更正权：您可以要求更正不准确的个人信息')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')

              Text('• 删除权：在特定情况下，您可以要求删除您的个人信息')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')

              Text('• 撤回同意：您可以随时撤回对信息处理的授权同意')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')

              Text('• 注销账号：您可以申请注销账号，我们将依法删除您的个人信息')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')

              Text('• 如您想行使上述权利，请联系我们的客服')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')
            }
            .width('100%')
            .padding({ left: 10 })
          }
          .width('100%')
          .padding({ left: 15, right: 15 })

          Column({ space: 15 }) {
            Text('六、未成年人保护')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .width('100%')

            Text('我们非常重视未成年人的隐私保护：')
              .fontSize(15)
              .fontColor('#666666')
              .width('100%')

            Column({ space: 10 }) {
              Text('• 我们的服务主要面向成年人')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')

              Text('• 若您是未满18周岁的未成年人，请在监护人的指导下使用我们的服务')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')

              Text('• 对于经监护人同意而收集的未成年人个人信息，我们只会在法律允许、监护人明确同意的情况下使用')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')

              Text('• 如果我们发现自己在未事先获得可证实的监护人同意的情况下收集了未成年人的个人信息，将会尽快删除相关数据')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')
            }
            .width('100%')
            .padding({ left: 10 })
          }
          .width('100%')
          .padding({ left: 15, right: 15 })

          Column({ space: 15 }) {
            Text('七、Cookie和类似技术')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .width('100%')

            Column({ space: 10 }) {
              Text('我们使用Cookie和类似技术来收集和存储您的信息，以实现以下功能：')
                .fontSize(15)
                .fontColor('#666666')
                .width('100%')

              Text('• 记住您的登录状态，避免重复登录')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')

              Text('• 保存您的偏好设置')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')

              Text('• 分析用户使用习惯，优化产品体验')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')

              Text('• 您可以通过浏览器设置管理或删除Cookie，但这可能影响某些功能的使用')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')
            }
            .width('100%')
            .padding({ left: 10 })
          }
          .width('100%')
          .padding({ left: 15, right: 15 })

          Column({ space: 15 }) {
            Text('八、隐私政策的变更')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .width('100%')

            Column({ space: 10 }) {
              Text('• 我们可能会不时更新本隐私政策')
                .fontSize(15)
                .fontColor('#666666')
                .width('100%')

              Text('• 当隐私政策发生重大变更时，我们会通过应用内公告、推送通知等方式告知您')
                .fontSize(15)
                .fontColor('#666666')
                .width('100%')

              Text('• 请您定期查阅隐私政策，了解我们如何保护您的信息')
                .fontSize(15)
                .fontColor('#666666')
                .width('100%')

              Text('• 继续使用我们的服务即表示您同意接受更新后的隐私政策')
                .fontSize(15)
                .fontColor('#666666')
                .width('100%')
            }
            .width('100%')
            .padding({ left: 10 })
          }
          .width('100%')
          .padding({ left: 15, right: 15 })

          Column({ space: 15 }) {
            Text('九、联系我们')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .width('100%')

            Column({ space: 10 }) {
              Text('如您对本隐私政策有任何疑问、意见或建议，请通过以下方式联系我们：')
                .fontSize(15)
                .fontColor('#666666')
                .width('100%')

              Text('客服电话：400-XXX-XXXX')
                .fontSize(15)
                .fontColor('#666666')
                .width('100%')

              Text('客服邮箱：privacy@example.com')
                .fontSize(15)
                .fontColor('#666666')
                .width('100%')

              Text('联系地址：XX省XX市XX区XX路XX号')
                .fontSize(15)
                .fontColor('#666666')
                .width('100%')

              Text('我们将在收到您的问题后15个工作日内予以回复')
                .fontSize(15)
                .fontColor('#666666')
                .width('100%')
            }
            .width('100%')
            .padding({ left: 10 })
          }
          .width('100%')
          .padding({ left: 15, right: 15 })

          Text('感谢您的信任与支持！')
            .fontSize(16)
            .fontColor('#FF5000')
            .width('100%')
            .textAlign(TextAlign.Center)
            .margin({ top: 20, bottom: 20 })
        }
        .width('100%')
        .padding({ top: 20, bottom: 20 })
        .backgroundColor('#FFFFFF')
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
