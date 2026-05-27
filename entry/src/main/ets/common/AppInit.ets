import userData from '../../../mock/user.json';
import productData from '../../../mock/product.json';
import { User, Product, GlobalStore } from '../model/Models';

/** 应用启动时加载商品与用户 mock 数据 */
export function initAppData(): void {
  GlobalStore.allProducts = (productData as Record<string, Object>)['data'] as Product[];
  const users = (userData as Record<string, Object>)['data'] as User[];
  GlobalStore.initUsers(users);
}

/** Preview 或未走 EntryAbility 时保证数据已加载 */
export function ensureAppData(): void {
  if (GlobalStore.allProducts.length === 0 || !GlobalStore.usersLoaded) {
    initAppData();
  }
}
