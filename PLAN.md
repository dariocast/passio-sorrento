# Holyweek Tracker - UI Refactoring Plan

## Overview
Transform the Holyweek Tracker Flutter app from a functional but basic UI to a modern, polished, and accessible experience following Material Design 3 principles.

---

## Phase 1: Foundation & Design System
**Duration**: 1 week | **Priority**: High | ✅ **COMPLETED**

### 1.1 Theme Enhancement
- [x] Extend `ThemeData` with full semantic color scheme
- [x] Create `AppColors` class with primary, secondary, tertiary, surface, error palettes
- [x] Implement light/dark color schemes with surface tint support
- [x] Add typography scale with explicit text styles (display, headline, title, body, label)
- [x] Create elevation tokens and shadow definitions

### 1.2 Shared Component Library
- [x] Build `AppCard` - enhanced Card with border, elevation, gradient options
- [x] Create `LiveBadge` - animated pulsing "LIVE" indicator
- [x] Implement `StateOverlay` - unified loading/error/empty states
- [x] Build `SkeletonLoader` - shimmer loading effect
- [x] Create button variants: `PrimaryButton`, `SecondaryButton`, `ConfraternityButton`
- [x] Implement `ConfraternityListItem` - enhanced list tile with live status

### 1.3 Color Utilities
- [x] Extract shared `_parseColor` function to `core/utils/color_utils.dart`
- [x] Add `_contrastColor` helper for accessibility
- [x] Create extension methods on `Color` class

---

## Phase 2: Navigation Redesign
**Duration**: 3-4 days | **Priority**: High | ✅ **COMPLETED**

### 2.1 Navigation Components
- [x] Replace AppBar icon buttons with `NavigationBar` at bottom
- [x] Add destinations: Home, Weather, Tracking, Settings (future)
- [x] Implement `NavigationRail` for tablet layouts (600-840dp)
- [x] Create adaptive navigation that switches Bar/Rail based on screen width

### 2.2 Route Management
- [x] Migrate from manual `generateRoute` to `go_router`
- [x] Add type-safe routes with path parameters
- [x] Implement route transitions (slide, fade)
- [x] Add deep linking support

---

## Phase 3: Home Page Enhancement
**Duration**: 4-5 days | **Priority**: High | ✅ **COMPLETED**

### 3.1 List Improvements
- [x] Replace simple `ListView` with pagination support (grouped by municipality)
- [x] Add shimmer loading skeletons
- [x] Implement pull-to-refresh with custom indicator
- [x] Group confraternities by municipality with section headers

### 3.2 Visual Hierarchy
- [x] Add "Live Now" section at top with horizontal scroll
- [x] Create featured card for active processions
- [x] Implement Hero animations from list to detail
- [x] Add quick action grid below list (Weather, Map icons)

### 3.3 Card Redesign
- [x] Redesign `ConfraternityListItem` with better spacing
- [x] Add confraternity color indicator as accent bar
- [x] Include municipality as subtitle with icon
- [x] Add action chevron with smooth animation
- [x] Implement swipe actions (quick info bottom sheet)

---

## Phase 4: Weather Page Modernization
**Duration**: 4-5 days | **Priority**: Medium | 🟡 **PARTIALLY COMPLETED**

### 4.1 Current Weather Display
- [x] Replace basic Card with gradient background
- [ ] Add animated weather condition icons
- [ ] Include temperature with trend indicator (arrow up/down)
- [ ] Add "procession-friendly" weather score (0-100%)
- [x] Include humidity, wind, UV index

### 4.2 Forecast Visualization
- [x] Add hourly forecast chart using `fl_chart` package
- [x] Implement 7-day forecast with day icons
- [ ] Add precipitation probability graph
- [ ] Create wind direction and speed visualization

### 4.3 Alert System
- [x] Add banner for high precipitation probability (>50%)
- [ ] Implement weather warnings with icons
- [ ] Add "best time for procession" recommendation

### 4.4 Tab Bar Enhancement
- [x] Replace basic tabs with styled containers
- [ ] Add municipality-specific background images
- [ ] Implement swipe gestures between municipalities
- [ ] Add quick jump to current location municipality

---

## Phase 5: Tracking Page Enhancements
**Duration**: 1 week | **Priority**: High | 🟡 **PARTIALLY COMPLETED**

### 5.1 Map Improvements
- [ ] Create custom map style with muted colors
- [x] Implement custom marker design with confraternity colors
- [ ] Add marker clustering for many processions
- [ ] Implement smooth marker interpolation between updates

### 5.2 Procession Details
- [x] Add bottom sheet when marker is selected
- [x] Include procession name, estimated arrival, route preview
- [ ] Add procession trail with gradient polyline
- [ ] Implement time slider to see procession history

### 5.3 User Location
- [ ] Add "my location" floating button
- [ ] Implement location permission flow
- [ ] Add distance calculation to processions
- [ ] Create "nearest active procession" feature

### 5.4 Filtering & Controls
- [x] Add filter FAB with municipality/confraternity filters
- [ ] Implement layer toggle (processions, churches, route)
- [ ] Add map style selector (streets, satellite, muted)
- [ ] Include offline map indicator

---

## Phase 6: Detail Page Richness
**Duration**: 3-4 days | **Priority**: Medium

### 6.1 Header Enhancement
- [ ] Add parallax effect to SliverAppBar background
- [ ] Include confraternity logo/icon in header
- [ ] Add contact information section
- [ ] Implement share button with deep link

### 6.2 Content Sections
- [ ] Add image gallery with swipeable photos
- [ ] Create procession schedule timeline
- [ ] Include statistics card (members, years, processions)
- [ ] Add related confraternities section
- [ ] Implement member information (future feature)

### 6.3 Actions
- [ ] Add "watch live" quick action button
- [ ] Include "add to calendar" for upcoming processions
- [ ] Add "subscribe to notifications" toggle
- [ ] Implement social sharing features

---

## Phase 7: Confraternity Detail Page
**Duration**: 3-4 days | **Priority**: Medium | 🟡 **PARTIALLY COMPLETED**

### 7.1 Hero Section
- [x] Redesign SliverAppBar with gradient overlay
- [x] Add confraternity color theming throughout page
- [ ] Include founding year and municipality badge
- [x] Add quick action buttons

### 7.2 Information Cards
- [x] Municipality card with weather shortcut
- [x] History section with expandable text
- [ ] Procession schedule card with timeline
- [ ] Contact information card

### 7.3 Navigation
- [x] Add "View on Map" primary action
- [x] Include "View Weather" shortcut
- [ ] Implement share functionality
- [ ] Add related confraternities carousel

---

## Phase 8: Shared Component Library Expansion
**Duration**: 1 week | **Priority**: Medium (ongoing) | 🟡 **PARTIALLY COMPLETED**

### 8.1 Map Components
- [x] `LiveMarker` - animated map marker with selection states
- [x] `MapOverlay` - bottom sheet overlay for selected item
- [x] `MapControls` - custom zoom, layer toggle, location button
- [ ] `ProcessionTrail` - gradient polyline for procession routes

### 8.2 Weather Components
- [ ] `WeatherIcon` - animated weather condition icons
- [ ] `TemperatureDisplay` - temperature with trend indicator
- [ ] `ForecastChart` - hourly/daily forecast visualization
- [x] `WeatherAlert` - precipitation warning banner

### 8.3 List Components
- [ ] `ProcessionTile` - swipeable tile with quick actions
- [ ] `ConfraternityGridItem` - grid layout for tablet
- [x] `MunicipalitySection` - section header with count
- [x] `LiveStatusIndicator` - real-time status badge

### 8.4 Feedback Components
- [x] `ErrorState` - unified error display with retry
- [x] `EmptyState` - placeholder for empty lists
- [x] `LoadingState` - skeleton loaders and progress
- [ ] `SuccessSnackbar` - confirmation messages

---

## Phase 9: Responsive & Adaptive Design
**Duration**: 1 week | **Priority**: Medium | 🟡 **PARTIALLY COMPLETED**

### 9.1 Breakpoint System
- [x] Define breakpoints: mobile (<600), tablet (600-840), desktop (>840)
- [x] Create `ResponsiveBuilder` widget
- [x] Implement `AdaptiveLayout` for automatic layout switching

### 9.2 Navigation Adaptation
- [ ] Mobile: NavigationBar with 4 destinations
- [ ] Tablet: NavigationRail on left + content area
- [ ] Desktop: NavigationRail + detail panel support
- [ ] Implement smooth transitions between nav types

### 9.3 Layout Reflow
- [ ] Home: Single column → 2-column grid → 3-column
- [ ] Detail: Stacked → Side-by-side (list + detail)
- [ ] Maps: Full screen → Split view with list
- [ ] Forms: Vertical stack → Side-by-side inputs

### 9.4 Touch Targets
- [ ] Ensure 48dp minimum touch targets
- [ ] Adjust spacing for different screen sizes
- [ ] Implement appropriate hover states for desktop
- [ ] Add cursor feedback for desktop interactions

---

## Phase 10: Accessibility & Internationalization
**Duration**: 1 week | **Priority**: Medium

### 10.1 Accessibility (a11y)
- [ ] Add semantic labels to all interactive elements
- [ ] Implement proper focus management
- [ ] Ensure 4.5:1 contrast ratio for text
- [ ] Add dynamic type support (text scaling)
- [ ] Implement proper content descriptions for images
- [ ] Add audio feedback for important events

### 10.2 Internationalization (i18n)
- [ ] Set up `flutter_localizations`
- [ ] Create translation files for Italian (default) and English
- [ ] Translate all hardcoded strings
- [ ] Format dates and numbers according to locale
- [ ] Implement right-to-left (RTL) support consideration

### 10.3 Screen Reader Support
- [ ] Add `Semantics` widget for custom widgets
- [ ] Implement proper reading order
- [ ] Add haptic feedback for important actions
- [ ] Ensure logical focus traversal

---

## Phase 11: Performance Optimization
**Duration**: Ongoing | **Priority**: Medium

### 11.1 List Performance
- [ ] Implement pagination for confraternity list
- [ ] Add virtual scrolling for large datasets
- [ ] Use `const` constructors throughout
- [ ] Implement item caching for list items

### 11.2 Image Optimization
- [ ] Add `cached_network_image` for images
- [ ] Implement appropriate image sizes for screens
- [ ] Add placeholder images with loading animation
- [ ] Implement lazy loading for gallery

### 11.3 Map Performance
- [ ] Implement marker clustering at low zoom
- [ ] Limit visible markers based on viewport
- [ ] Add tile caching strategy
- [ ] Optimize marker rendering with canvaskit

### 11.4 State Management
- [ ] Optimize Bloc rebuilds with selective listening
- [ ] Implement state immutability with Equatable
- [ ] Add debouncing for search and filters
- [ ] Implement connection-aware data fetching

---

## Phase 12: Animations & Micro-interactions
**Duration**: 1 week | **Priority**: Low (enhancement) | 🟡 **PARTIALLY COMPLETED**

### 12.1 Page Transitions
- [ ] Add Hero animations between list and detail
- [ ] Implement shared element transitions
- [x] Add route transition animations (slide, fade, scale)
- [ ] Create bottom sheet enter/exit animations

### 12.2 List Animations
- [ ] Implement staggered fade-in for list items
- [ ] Add slide-in animation for new items
- [ ] Implement scale effects on item selection
- [ ] Create refresh indicator animations

### 12.3 Feedback Animations
- [ ] Add scale on tap for buttons
- [ ] Implement ripple effect customization
- [ ] Create success/error animations
- [x] Add pulsing effect for live indicators

### 12.4 Weather Animations
- [ ] Animated weather condition icons
- [ ] Rain/snow particle effects
- [ ] Sun animation for clear weather
- [ ] Cloud movement animations

---

## Phase 13: Testing & Quality Assurance
**Duration**: 1 week | **Priority**: High

### 13.1 Widget Testing
- [ ] Write widget tests for all new components
- [ ] Test responsive layouts on different screen sizes
- [ ] Implement golden tests for visual regression
- [ ] Test accessibility with TalkBack/VoiceOver

### 13.2 Integration Testing
- [ ] Test navigation flows
- [ ] Verify state management integration
- [ ] Test error handling and recovery
- [ ] Performance testing on low-end devices

### 13.3 Visual QA
- [ ] Review light/dark mode consistency
- [ ] Check all screen sizes and orientations
- [ ] Verify animations are smooth (60fps)
- [ ] Test with different text scaling factors

### 13.4 Documentation
- [ ] Document component usage guidelines
- [ ] Create theme customization guide
- [ ] Add accessibility testing procedures
- [ ] Document responsive design patterns

---

## Dependencies to Add

### Core UI Packages
```yaml
dependencies:
  go_router: ^14.0.0          # Type-safe routing
  shimmer: ^3.0.0             # Loading skeletons
  cached_network_image: ^3.4.0 # Image caching
  fl_chart: ^0.68.0           # Charts and graphs
  intl: ^0.20.2              # Date formatting
```

### Map Packages (Optional)
```yaml
dependencies:
  flutter_map: ^8.2.2         # Already in use
  flutter_map_tile_caching: ^10.0.0 # Offline tiles
```

### Responsive Utils
```yaml
dependencies:
  window_size: ^0.4.0         # Window dimensions
```

---

## Implementation Order (Recommended)

### Quick Wins (Week 1)
1. Add shimmer loading skeletons
2. Create shared color utilities
3. Implement pull-to-refresh on all pages
4. Add animated "LIVE" badge
5. Upgrade error states with retry actions

### Core Foundation (Weeks 2-3)
1. Theme enhancement with full color scheme
2. Shared component library
3. Navigation redesign (NavigationBar)
4. Route management improvements

### Feature Enhancement (Weeks 4-6)
1. Home page redesign
2. Weather page charts
3. Map improvements
4. Detail page enhancements

### Polish (Weeks 7-8)
1. Responsive design implementation
2. Accessibility improvements
3. Internationalization
4. Performance optimization
5. Animations and micro-interactions

### Quality (Week 9)
1. Testing
2. Documentation
3. Bug fixes
4. Visual QA

---

## File Structure Changes

### New Directory Structure
```
lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_text_theme.dart
│   │   └── app_theme.dart
│   ├── components/
│   │   ├── app_card.dart
│   │   ├── live_badge.dart
│   │   ├── state_overlay.dart
│   │   ├── skeleton_loader.dart
│   │   └── buttons/
│   │       ├── primary_button.dart
│   │       └── confraternity_button.dart
│   ├── utils/
│   │   ├── color_utils.dart
│   │   └── responsive_utils.dart
│   └── extensions/
│       └── color_extension.dart
├── shared/
│   ├── widgets/
│   │   ├── weather/
│   │   │   ├── weather_icon.dart
│   │   │   ├── temperature_display.dart
│   │   │   └── forecast_chart.dart
│   │   ├── map/
│   │   │   ├── live_marker.dart
│   │   │   └── procession_trail.dart
│   │   └── lists/
│   │       ├── confraternity_list_item.dart
│   │       └── procession_tile.dart
│   └── components/
│       └── error_state.dart
└── features/
    └── [existing structure]
```

---

## Success Metrics

### Visual Quality
- [ ] Consistent spacing and typography across all screens
- [ ] Smooth animations (60fps) on all devices
- [ ] Beautiful light and dark mode themes
- [ ] Professional-looking cards and overlays

### User Experience
- [ ] Intuitive navigation with clear hierarchy
- [ ] Quick access to live information
- [ ] Clear error states with recovery options
- [ ] Responsive design that works on all devices

### Accessibility
- [ ] WCAG AA compliance
- [ ] Full screen reader support
- [ ] Proper contrast ratios
- [ ] Support for dynamic text scaling

### Performance
- [ ] 60fps animations
- [ ] Fast list scrolling (no jank)
- [ ] Efficient map rendering
- [ ] Quick page transitions

---

## Notes for Future Development

### Consider for Phase 2
- User accounts and authentication
- Push notifications for procession updates
- Offline mode with local database
- Social features (comments, photos)
- In-app donations or merchandise

### Design Principles
- Mobile-first approach
- Dark mode support throughout
- Consistent with Holy Week tradition
- Clean, minimal, modern aesthetic
- Accessible to all users

---

## References & Inspiration

### Design Systems
- [Material Design 3](https://m3.material.io/)
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

### Flutter Resources
- [Flutter Widget of the Week](https://www.youtube.com/playlist?list=PLjxrf2q8roU23XGwz3Km7sQZFTdB996iG)
- [Material 3 Flutter Samples](https://github.com/flutter/samples/tree/main/material_3_demo)

### UI Inspiration
- Weather apps with clean data visualization
- Live tracking applications
- Event and schedule applications
- Traditional vs modern fusion design

---

## Timeline Estimate

| Phase | Duration | Total Weeks |
|-------|----------|-------------|
| Phase 1: Foundation | 1 week | Week 1 |
| Phase 2: Navigation | 3-4 days | Week 2 |
| Phase 3: Home Page | 4-5 days | Week 2-3 |
| Phase 4: Weather Page | 4-5 days | Week 3-4 |
| Phase 5: Tracking Page | 1 week | Week 4-5 |
| Phase 6: Detail Page | 3-4 days | Week 5 |
| Phase 7: Components | 1 week | Week 6 |
| Phase 8: Responsive | 1 week | Week 6-7 |
| Phase 9: a11y + i18n | 1 week | Week 7-8 |
| Phase 10: Performance | Ongoing | Week 8 |
| Phase 11: Animations | 1 week | Week 8-9 |
| Phase 12: Testing | 1 week | Week 9 |

**Total Estimated Time**: 9-10 weeks

---

*Document generated for Holyweek Tracker Flutter App UI Refactoring*
*Last updated: January 19, 2026*

---

## Implementation Progress Summary

| Phase | Status | Completion |
|-------|--------|------------|
| Phase 1: Foundation | ✅ Complete | 100% |
| Phase 2: Navigation | ✅ Complete | 100% |
| Phase 3: Home Page | ✅ Complete | 100% |
| Phase 4: Weather Page | 🟡 Partial | 55% |
| Phase 5: Tracking Page | 🟡 Partial | 45% |
| Phase 6: Detail Page | ⬜ Not Started | 0% |
| Phase 7: Confraternity Detail | 🟡 Partial | 65% |
| Phase 8: Component Library | 🟡 Partial | 50% |
| Phase 9: Responsive Design | 🟡 Partial | 25% |
| Phase 10: Accessibility | ⬜ Not Started | 0% |
| Phase 11: Performance | ⬜ Not Started | 0% |
| Phase 12: Animations | 🟡 Partial | 15% |
| Phase 13: Testing | ⬜ Not Started | 0% |

### Files Created/Modified

**New Core Files:**
- `lib/core/theme/app_colors.dart` - Color palette
- `lib/core/theme/app_text_theme.dart` - Typography
- `lib/core/theme/app_theme.dart` - Theme configuration
- `lib/core/components/app_card.dart` - Enhanced cards
- `lib/core/components/buttons.dart` - Button variants
- `lib/core/components/live_badge.dart` - Animated badges
- `lib/core/components/skeleton_loader.dart` - Shimmer loaders
- `lib/core/components/state_overlay.dart` - State displays
- `lib/core/components/confraternity_list_item.dart` - List items
- `lib/core/utils/color_utils.dart` - Color utilities
- `lib/core/utils/responsive_utils.dart` - Responsive utilities
- `lib/core/router/app_router.dart` - go_router configuration
- `lib/core/navigation/app_shell.dart` - Adaptive navigation shell

**Modified Feature Files:**
- `lib/main.dart` - Updated to use MaterialApp.router with go_router
- `lib/features/home/presentation/pages/home_page.dart` - Redesigned with go_router
- `lib/features/home/presentation/pages/confraternity_detail_page.dart` - Enhanced with go_router
- `lib/features/weather/presentation/pages/weather_page.dart` - Modernized
- `lib/features/tracking/presentation/pages/tracking_page.dart` - Improved with go_router

**Dependencies Added:**
- `go_router: ^14.0.0`
- `shimmer: ^3.0.0`
- `cached_network_image: ^3.4.0`
- `fl_chart: ^0.68.0`
- `google_fonts: ^6.2.1`
