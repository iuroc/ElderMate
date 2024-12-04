import { PageBuilder as ChatPageBuilder } from '../Chat/Page'
import { PageBuilder as MorePageBuilder } from '../More/Page'
import { PageBuilder as SharePageBuilder } from '../Share/Page'
import { PageBuilder as TestPageBuilder } from '../Test/Page'
import { PageBuilder as UserPageBuilder } from '../User/Page'

@Builder
export function PageMap(name: string) {
    if (name == 'Chat') {
        ChatPageBuilder()
    } else if (name == 'Share') {
        SharePageBuilder()
    } else if (name == 'More') {
        MorePageBuilder()
    } else if (name == 'User') {
        UserPageBuilder()
    } else if (name == 'Test') {
        TestPageBuilder()
    }
}