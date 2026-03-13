# nova_admin

Admin dashboard for Nova applications — inspired by Phoenix LiveDashboard.

Built with [arizona_core](https://github.com/Taure/arizona_core) for server-rendered views with a path to live WebSocket updates.

## Pages

- **Dashboard** — OTP release, ERTS version, uptime, schedulers, memory breakdown, resource counts
- **Processes** — all BEAM processes with memory, reductions, message queue (click for detail)
- **ETS Tables** — all tables with type, size, memory, protection (click to view entries)
- **Ports** — port list with I/O stats
- **Applications** — running applications with supervision tree visualization
- **Routes** — Nova route table with method, path, controller, function

## Requirements

- OTP 28+
- Nova 0.13+
- arizona_core

## Installation

Add nova_admin to your `rebar.config`:

```erlang
{deps, [
    {nova_admin, {git, "https://github.com/novaframework/nova_admin.git", {branch, "main"}}}
]}.
```

Add to your application dependencies in `app.src`:

```erlang
{applications, [kernel, stdlib, nova, arizona_core, nova_admin]}
```

Register it in your `sys.config`:

```erlang
{your_application, [
    {nova_apps, [nova_admin]}
]}.
```

Browse to `http://localhost:YOUR_PORT/admin`.

## Configuration

The prefix is configurable via application environment:

```erlang
{nova_admin, [
    {prefix, "/dashboard"}  %% default: "/admin"
]}.
```

## Architecture

nova_admin is a stateless library — no supervision tree, no gen_servers. All data comes from BEAM introspection at request time (`erlang:processes()`, `ets:all()`, `application:which_applications()`, etc.).

Views use arizona_core's `arizona_view` behaviour with the `arizona_parse_transform` for compile-time template optimization. This means views can be upgraded to live WebSocket updates without rewriting templates.
