# Frontend Development Checklist (Vue.js)

## Component Architecture

### Component Design
- [ ] **Single Responsibility**: Each component has one clear purpose
- [ ] **Composition over Inheritance**: Use composition patterns
- [ ] **Prop Drilling**: Avoid excessive prop drilling (> 2-3 levels)
- [ ] **Component Size**: Keep components small (< 200 lines)
- [ ] **Reusability**: Identify and extract reusable patterns

### Component Structure
```
components/
├── ui/              # Reusable UI primitives (Button, Input, Card)
├── features/        # Feature-specific components
├── layouts/         # Layout components (Header, Footer, Sidebar)
└── shared/          # Shared business components
```

### Vue Component Patterns
- **Presentational vs Container**: Separate UI from logic
- **Composables**: Extract and reuse stateful logic (Vue's composables)
- **Provide/Inject**: For deep prop passing without drilling
- **Slots**: For flexible component composition
- **v-model**: For two-way data binding in custom components

### Composition API Best Practices
```vue
<script setup>
import { ref, computed, watch, onMounted } from 'vue'

// Refs for reactive state
const count = ref(0)

// Computed for derived state
const doubleCount = computed(() => count.value * 2)

// Watchers for side effects
watch(count, (newVal, oldVal) => {
  console.log(`Count changed from ${oldVal} to ${newVal}`)
})

// Lifecycle hooks
onMounted(() => {
  console.log('Component mounted')
})
</script>
```

## State Management with Pinia

### Store Structure
```javascript
// stores/user.js
import { defineStore } from 'pinia'

export const useUserStore = defineStore('user', {
  state: () => ({
    currentUser: null,
    isAuthenticated: false,
    preferences: {}
  }),
  
  getters: {
    fullName: (state) => {
      return `${state.currentUser?.firstName} ${state.currentUser?.lastName}`
    },
    hasPermission: (state) => (permission) => {
      return state.currentUser?.permissions.includes(permission)
    }
  },
  
  actions: {
    async login(credentials) {
      const response = await api.login(credentials)
      this.currentUser = response.data
      this.isAuthenticated = true
    },
    
    logout() {
      this.currentUser = null
      this.isAuthenticated = false
    }
  }
})
```

### State Location
- [ ] **Local State**: Component-specific state (ref, reactive)
- [ ] **Lifted State**: Shared state via props/events or composables
- [ ] **Global State**: App-wide state (Pinia stores)
- [ ] **Server State**: API data (with stores or composables)
- [ ] **URL State**: Router state for shareable/bookmarkable state

### State Anti-Patterns
- ❌ Duplicating server data in local state
- ❌ Storing derived data in state (use computed instead)
- ❌ Over-using global stores for local concerns
- ❌ Not normalizing nested/relational data
- ❌ Mutating state outside actions (in Pinia)

### State Best Practices
- ✅ Normalize complex data structures
- ✅ Use Pinia actions for complex state logic
- ✅ Implement optimistic updates
- ✅ Handle loading, error, and success states
- ✅ Use getters for derived state
- ✅ Use composables for reusable state logic

### Composables Pattern
```javascript
// composables/useCounter.js
import { ref, computed } from 'vue'

export function useCounter(initialValue = 0) {
  const count = ref(initialValue)
  const double = computed(() => count.value * 2)
  
  function increment() {
    count.value++
  }
  
  function decrement() {
    count.value--
  }
  
  return {
    count,
    double,
    increment,
    decrement
  }
}
```

## CSS Architecture

### Styling Approaches
- **Scoped Styles**: Vue's `<style scoped>` for component isolation
- **CSS Modules**: `<style module>` for programmatic styles
- **Tailwind CSS**: Utility-first, rapid development
- **UnoCSS**: Instant on-demand atomic CSS (recommended for Vue)
- **BEM**: Block-Element-Modifier, traditional approach
- **CSS Variables**: For theming and design tokens

### Vue Style Features
```vue
<template>
  <div :class="$style.container">
    <button :class="{ active: isActive }">Click me</button>
  </div>
</template>

<style scoped>
/* Scoped styles only apply to this component */
.container {
  padding: 1rem;
}

/* Deep selector for child components */
:deep(.child-class) {
  color: red;
}

/* Slotted content styling */
:slotted(button) {
  margin: 0.5rem;
}
</style>

<style module>
/* CSS Modules for programmatic access */
.container {
  background: var(--primary-color);
}
</style>
```

### CSS Best Practices
- [ ] **Mobile First**: Start with mobile, enhance for larger screens
- [ ] **Avoid Magic Numbers**: Use design tokens/variables
- [ ] **Consistent Spacing**: Use spacing scale (4px, 8px, 16px...)
- [ ] **Typography Scale**: Define heading and text sizes
- [ ] **Color Palette**: Limit and systemize colors
- [ ] **Avoid !important**: Indicates specificity issues
- [ ] **Performance**: Minimize layout thrashing and repaints

### Responsive Design
```css
/* Mobile first approach */
.component { /* Mobile styles */ }

@media (min-width: 640px) { /* Tablet */ }
@media (min-width: 1024px) { /* Desktop */ }
@media (min-width: 1280px) { /* Large desktop */ }
```

## Performance Optimization

### Rendering Performance
- [ ] **v-once**: Render element/component only once
- [ ] **v-memo**: Memoize template sub-tree (Vue 3.2+)
- [ ] **Computed Properties**: Use for derived data (automatically cached)
- [ ] **Lazy Loading**: Code split with defineAsyncComponent
- [ ] **Virtual Scrolling**: Render only visible items in long lists
- [ ] **Debounce/Throttle**: Rate-limit expensive operations
- [ ] **v-show vs v-if**: Use v-show for frequent toggles

```vue
<script setup>
import { defineAsyncComponent } from 'vue'

// Lazy load heavy component
const HeavyComponent = defineAsyncComponent(() =>
  import('./HeavyComponent.vue')
)
</script>

<template>
  <!-- Only render once -->
  <div v-once>{{ staticContent }}</div>
  
  <!-- Memoize with dependencies -->
  <div v-memo="[valueA, valueB]">
    {{ expensiveComputation }}
  </div>
  
  <!-- Use v-show for frequent toggles -->
  <div v-show="isVisible">Toggle me often</div>
  
  <!-- Use v-if for conditional rendering -->
  <div v-if="shouldRender">Render conditionally</div>
</template>
```

### Bundle Optimization
- [ ] **Code Splitting**: Split by route with lazy loading
- [ ] **Tree Shaking**: Remove unused code (works well with Vue 3)
- [ ] **Minimize Dependencies**: Audit and remove unused packages
- [ ] **Dynamic Imports**: Load heavy libraries only when needed
- [ ] **Asset Optimization**: Compress images, use modern formats (WebP, AVIF)
- [ ] **Vite Optimization**: Leverage Vite's fast build and HMR

### Loading Strategies
- [ ] **Suspense**: Show fallback while async components load
- [ ] **Skeleton Screens**: Show layout while loading
- [ ] **Progressive Loading**: Load critical content first
- [ ] **Prefetching**: Prefetch likely next routes/data
- [ ] **Service Workers**: Cache assets for offline support

```vue
<template>
  <Suspense>
    <template #default>
      <AsyncComponent />
    </template>
    <template #fallback>
      <LoadingSpinner />
    </template>
  </Suspense>
</template>
```

## Accessibility (a11y)

### Semantic HTML
- [ ] Use semantic elements (header, nav, main, article, aside, footer)
- [ ] Proper heading hierarchy (h1 → h2 → h3, no skipping)
- [ ] Use button for actions, anchor for navigation
- [ ] Label form inputs properly (label, aria-label, aria-labelledby)

### Keyboard Navigation
- [ ] All interactive elements are keyboard accessible
- [ ] Logical tab order (tabIndex when necessary)
- [ ] Focus indicators visible
- [ ] Skip links for navigation
- [ ] Trap focus in modals

### Screen Readers
- [ ] Alt text for images (empty alt for decorative)
- [ ] ARIA attributes when semantic HTML isn't enough
- [ ] aria-live regions for dynamic content
- [ ] Meaningful link text (not "click here")
- [ ] Form validation errors announced

### WCAG Compliance
- [ ] **Perceivable**: Text alternatives, distinguishable content
- [ ] **Operable**: Keyboard accessible, enough time, no seizures
- [ ] **Understandable**: Readable, predictable, input assistance
- [ ] **Robust**: Compatible with assistive technologies

## API Integration

### API Calls with Composables
```javascript
// composables/useApi.js
import { ref, unref } from 'vue'

export function useFetch(url) {
  const data = ref(null)
  const error = ref(null)
  const loading = ref(false)

  async function fetch() {
    loading.value = true
    error.value = null
    
    try {
      const response = await fetch(unref(url))
      data.value = await response.json()
    } catch (e) {
      error.value = e
    } finally {
      loading.value = false
    }
  }

  return { data, error, loading, fetch }
}
```

### API Integration with Pinia
```javascript
// stores/posts.js
import { defineStore } from 'pinia'

export const usePostsStore = defineStore('posts', {
  state: () => ({
    posts: [],
    currentPost: null,
    loading: false,
    error: null
  }),
  
  actions: {
    async fetchPosts() {
      this.loading = true
      this.error = null
      
      try {
        const response = await fetch('/api/posts')
        this.posts = await response.json()
      } catch (error) {
        this.error = error.message
      } finally {
        this.loading = false
      }
    },
    
    async createPost(postData) {
      // Optimistic update
      const tempId = Date.now()
      const tempPost = { ...postData, id: tempId }
      this.posts.push(tempPost)
      
      try {
        const response = await fetch('/api/posts', {
          method: 'POST',
          body: JSON.stringify(postData)
        })
        const newPost = await response.json()
        
        // Replace temp post with real one
        const index = this.posts.findIndex(p => p.id === tempId)
        this.posts[index] = newPost
      } catch (error) {
        // Rollback on error
        this.posts = this.posts.filter(p => p.id !== tempId)
        this.error = error.message
      }
    }
  }
})
```

### API Calls Best Practices
- [ ] **Loading States**: Show feedback during requests
- [ ] **Error Handling**: Display user-friendly error messages
- [ ] **Retry Logic**: Retry failed requests with backoff
- [ ] **Cancellation**: Cancel requests on component unmount
- [ ] **Caching**: Cache responses to reduce requests
- [ ] **Pagination**: Load data in chunks
- [ ] **Optimistic Updates**: Update UI before server confirms

## Forms & Validation

### Form Handling with v-model
```vue
<script setup>
import { ref, reactive } from 'vue'

// Simple form with refs
const email = ref('')
const password = ref('')

// Complex form with reactive
const form = reactive({
  name: '',
  email: '',
  age: null,
  terms: false
})

function handleSubmit() {
  console.log('Form data:', form)
}
</script>

<template>
  <form @submit.prevent="handleSubmit">
    <input v-model="form.name" type="text" />
    <input v-model="form.email" type="email" />
    <input v-model.number="form.age" type="number" />
    <input v-model="form.terms" type="checkbox" />
    <button type="submit">Submit</button>
  </form>
</template>
```

### Form Validation
- [ ] **Controlled Components**: v-model for two-way binding
- [ ] **Validation**: Client-side + server-side
- [ ] **Error Display**: Show errors inline near fields
- [ ] **Submit State**: Disable submit while processing
- [ ] **Reset**: Clear form after successful submit
- [ ] **Autosave**: For long forms, save drafts

### Validation Libraries for Vue
- **Vuelidate**: Lightweight, flexible validation
- **VeeValidate**: Full-featured form validation
- **Yup/Zod**: Schema validation (works with VeeValidate)

### VeeValidate Example
```vue
<script setup>
import { useForm, useField } from 'vee-validate'
import * as yup from 'yup'

const schema = yup.object({
  email: yup.string().required().email(),
  password: yup.string().required().min(8)
})

const { handleSubmit, errors } = useForm({
  validationSchema: schema
})

const { value: email } = useField('email')
const { value: password } = useField('password')

const onSubmit = handleSubmit((values) => {
  console.log('Valid form!', values)
})
</script>

<template>
  <form @submit="onSubmit">
    <div>
      <input v-model="email" type="email" />
      <span v-if="errors.email">{{ errors.email }}</span>
    </div>
    <div>
      <input v-model="password" type="password" />
      <span v-if="errors.password">{{ errors.password }}</span>
    </div>
    <button type="submit">Submit</button>
  </form>
</template>
```

## Testing Strategy

### Unit Tests (Vitest)
```javascript
// Button.spec.js
import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import Button from './Button.vue'

describe('Button', () => {
  it('renders properly', () => {
    const wrapper = mount(Button, { props: { label: 'Click me' } })
    expect(wrapper.text()).toContain('Click me')
  })
  
  it('emits click event', async () => {
    const wrapper = mount(Button)
    await wrapper.trigger('click')
    expect(wrapper.emitted()).toHaveProperty('click')
  })
})
```

### Testing Composables
```javascript
// useCounter.spec.js
import { describe, it, expect } from 'vitest'
import { useCounter } from './useCounter'

describe('useCounter', () => {
  it('increments count', () => {
    const { count, increment } = useCounter(0)
    expect(count.value).toBe(0)
    increment()
    expect(count.value).toBe(1)
  })
})
```

### Testing Pinia Stores
```javascript
// user.store.spec.js
import { setActivePinia, createPinia } from 'pinia'
import { useUserStore } from './user'

describe('User Store', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
  })
  
  it('logs in user', async () => {
    const store = useUserStore()
    await store.login({ email: 'test@test.com', password: '123' })
    expect(store.isAuthenticated).toBe(true)
  })
})
```

### E2E Tests (Playwright/Cypress)
- Test critical user journeys
- Test across browsers
- Test responsive behavior

### Testing Best Practices
- [ ] Test behavior, not implementation
- [ ] Use data-test-id for test selectors
- [ ] Test accessibility (screen reader behavior)
- [ ] Test error states and edge cases
- [ ] Keep tests maintainable and fast

## Common Frontend Anti-Patterns

### ❌ Anti-Pattern: God Component
```vue
<!-- 500+ lines component doing everything -->
<script setup>
// authentication logic
// data fetching
// business logic
// complex state management
// form handling
// ...
</script>
```

### ✅ Solution: Decompose
```vue
<script setup>
import UserProfile from './UserProfile.vue'
import ActivityFeed from './ActivityFeed.vue'
import SettingsPanel from './SettingsPanel.vue'
</script>

<template>
  <DashboardLayout>
    <UserProfile />
    <ActivityFeed />
    <SettingsPanel />
  </DashboardLayout>
</template>
```

### ❌ Anti-Pattern: Prop Drilling
Passing props through many levels of components.

### ✅ Solution: Provide/Inject or Pinia
```vue
<!-- Parent component -->
<script setup>
import { provide } from 'vue'

const theme = ref('dark')
provide('theme', theme)
</script>

<!-- Deep child component -->
<script setup>
import { inject } from 'vue'

const theme = inject('theme')
</script>
```

### ❌ Anti-Pattern: Not Using Computed
Calculating derived state in methods or template.

### ✅ Solution: Use Computed Properties
```vue
<script setup>
import { ref, computed } from 'vue'

const items = ref([...])

// ✅ Computed (cached, only recalculates when items changes)
const filteredItems = computed(() => {
  return items.value.filter(item => item.active)
})

// ❌ Method (recalculates on every render)
function getFilteredItems() {
  return items.value.filter(item => item.active)
}
</script>
```

### ❌ Anti-Pattern: Mutating Props
```vue
<script setup>
const props = defineProps(['value'])

// ❌ Don't mutate props directly
props.value = 'new value'
</script>
```

### ✅ Solution: Emit Events
```vue
<script setup>
const props = defineProps(['modelValue'])
const emit = defineEmits(['update:modelValue'])

function updateValue(newValue) {
  emit('update:modelValue', newValue)
}
</script>
```

## Security Considerations

- [ ] **XSS Prevention**: Vue escapes content by default, avoid v-html with user input
- [ ] **CSRF Protection**: Use tokens for state-changing operations
- [ ] **Secure Storage**: Don't store sensitive data in localStorage
- [ ] **Content Security Policy**: Implement CSP headers
- [ ] **Input Validation**: Validate on frontend and backend
- [ ] **Dependencies**: Audit for vulnerabilities regularly (npm audit)

## Vue Router Best Practices

### Route Organization
```javascript
// router/index.js
import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/',
    component: () => import('@/layouts/MainLayout.vue'),
    children: [
      {
        path: '',
        name: 'home',
        component: () => import('@/views/Home.vue')
      },
      {
        path: 'profile',
        name: 'profile',
        component: () => import('@/views/Profile.vue'),
        meta: { requiresAuth: true }
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// Navigation guard
router.beforeEach((to, from) => {
  if (to.meta.requiresAuth && !isAuthenticated()) {
    return { name: 'login' }
  }
})

export default router
```

## Checklist Summary

Before implementing frontend:
1. ✅ Component structure planned and logical?
2. ✅ State management strategy defined (Pinia stores vs composables)?
3. ✅ Styling approach chosen and consistent?
4. ✅ Performance considerations addressed (v-memo, lazy loading)?
5. ✅ Accessibility requirements met?
6. ✅ API integration planned (composables or stores)?
7. ✅ Form validation strategy in place (VeeValidate/Vuelidate)?
8. ✅ Testing approach defined (Vitest + Testing Library)?
9. ✅ Security measures implemented?
10. ✅ Responsive design considered?
