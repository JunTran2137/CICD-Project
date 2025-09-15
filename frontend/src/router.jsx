import React, { Suspense, lazy } from 'react'
import { Switch, Route, Redirect } from 'react-router-dom'

export default function AppRoute(props) {
  return (
    <Suspense fallback={''}>
      <Switch>
        <Route path="/" component={(p) => <Redirect to="/product" /> } exact />
        <Route path="/product" component={lazy(() => import('./components/product/Index'))} exact />
        <Route path="/product/create" component={lazy(() => import('./components/product/Create'))} exact />
        <Route path="/product/:id/" component={lazy(() => import('./components/product/Detail'))} exact />
        <Route path="/product/edit/:id/" component={lazy(() => import('./components/product/Edit'))} exact />
        <Route path="/product/delete/:id/" component={lazy(() => import('./components/product/Delete'))} exact />
      </Switch>
    </Suspense>
  )
}