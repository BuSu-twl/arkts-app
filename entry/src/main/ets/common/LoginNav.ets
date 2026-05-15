import router from '@ohos.router';
import { GlobalStore, PayRouteParams } from '../model/Models';

/** 登录/注册成功后：若有待支付订单则回到支付页，否则进首页 */
export function navigateAfterLogin(): void {
  let pending = GlobalStore.consumePendingPay();
  if (pending !== null) {
    router.replaceUrl({ url: 'pages/PayPage', params: pending as PayRouteParams });
  } else {
    router.replaceUrl({ url: 'pages/HomePage' });
  }
}
