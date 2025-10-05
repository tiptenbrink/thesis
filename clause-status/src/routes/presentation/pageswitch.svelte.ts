import { requestPage, requestPageIncrement, requestSetPage } from '$lib/client/state';
import { lastSlide } from '$lib/content/order';

export interface PageState {
  page: number
  animation: number
  
  
  syncPage(): Promise<void>

  incrPage(isLastAnimation: boolean): Promise<void>

  decrPage(): Promise<void>

  handleKeyDown(event: KeyboardEvent, isLastAnimation: boolean): void
}

export function createPage(initialValue: number, onPageChange?: (pre: number, post: number) => void): PageState {
    class PageStateClass {
      page: number = $state(initialValue)
      animation: number = $state(0)
      onPageChange: (pre: number, post: number) => void = () => { /* Do nothing by default */ }

      constructor(onPageChange?: (pre: number, post: number) => void) {
        if (onPageChange !== undefined) {
          this.onPageChange = onPageChange
        }
      }
    
      async syncPage() {
        const reqPage = await requestPage()
    
        if (this.page != reqPage.page) {
          const oldPage = this.page
          this.onPageChange(oldPage, reqPage.page)
          this.page = reqPage.page
        }
        if (this.animation != reqPage.animation) {
          this.animation = reqPage.animation
        }
      }
    
      async incrPage(isLastAnimation: boolean = true) {
        if (!isLastAnimation) {
          await requestPageIncrement(1, 'animation')
          await this.syncPage()
          return
        }

        await requestSetPage(0, 'animation')

        if (this.page < lastSlide) {
          await requestPageIncrement(1)
          await this.syncPage()
        }
      }
    
      async decrPage() {
        if (this.animation > 0) {
          await requestPageIncrement(-1, 'animation')
          await this.syncPage()
          return
        }
        
        if (this.page > 0) {
          await requestPageIncrement(-1)
          await requestSetPage(0, 'animation')
          await this.syncPage()
        }
      }
    
    
      handleKeyDown(event: KeyboardEvent, isLastAnimation: boolean = true) {
        if (event.key === 'ArrowRight' || event.key === 'PageDown' || event.key === 'ArrowDown') {
          this.incrPage(isLastAnimation).then();
        } else if (event.key === 'ArrowLeft' || event.key === 'PageUp' || event.key === 'ArrowUp') {
          this.decrPage().then();
        }
      }
    }

    return new PageStateClass(onPageChange)
}

