/*
 *  Phusion Passenger - https://www.phusionpassenger.com/
 *  Copyright (c) 2010-2017 Phusion Holding B.V.
 *
 *  "Passenger", "Phusion Passenger" and "Union Station" are registered
 *  trademarks of Phusion Holding B.V.
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 */

/*
 * ConfigGeneral/AutoGeneratedDefinitions.cpp is automatically generated from
 * ConfigGeneral/AutoGeneratedDefinitions.cpp.cxxcodebuilder,
 * using ConfigGeneral/AutoGenerateddefinitions from src/ruby_supportlib/phusion_passenger/apache2/config_options.rb.
 * Edits to ConfigGeneral/AutoGeneratedDefinitions.cpp will be lost.
 *
 * To update ConfigGeneral/AutoGeneratedDefinitions.cpp:
 *   rake apache2
 *
 * To force regeneration of ConfigGeneral/AutoGeneratedDefinitions.cpp:
 *   rm -f src/apache2_module/ConfigGeneral/AutoGeneratedDefinitions.cpp
 *   rake src/apache2_module/ConfigGeneral/AutoGeneratedDefinitions.cpp
 */

AP_INIT_TAKE1("PassengerAdminPanelAuthType",
	(Take1Func) cmd_passenger_admin_panel_auth_type,
	NULL,
	RSRC_CONF,
	"The authentication type to use when connecting to the admin panel"),
AP_INIT_TAKE1("PassengerAdminPanelPassword",
	(Take1Func) cmd_passenger_admin_panel_password,
	NULL,
	RSRC_CONF,
	"The password to use when connecting to the admin panel using basic authentication"),
AP_INIT_TAKE1("PassengerAdminPanelUrl",
	(Take1Func) cmd_passenger_admin_panel_url,
	NULL,
	RSRC_CONF,
	"Connect to an admin panel at the given connector URL"),
AP_INIT_TAKE1("PassengerAdminPanelUsername",
	(Take1Func) cmd_passenger_admin_panel_username,
	NULL,
	RSRC_CONF,
	"The username to use when connecting to the admin panel using basic authentication"),
AP_INIT_FLAG("PassengerAllowEncodedSlashes",
	(FlagFunc) cmd_passenger_allow_encoded_slashes,
	NULL,
	RSRC_CONF | ACCESS_CONF | OR_OPTIONS,
	"Whether to support encoded slashes in the URL"),
AP_INIT_TAKE1("PassengerAnalyticsLogGroup",
	(Take1Func) cmd_passenger_analytics_log_group,
	NULL,
	RSRC_CONF,
	"Obsolete option."),
AP_INIT_TAKE1("PassengerAnalyticsLogUser",
	(Take1Func) cmd_passenger_analytics_log_user,
	NULL,
	RSRC_CONF,
	"Obsolete option."),
AP_INIT_TAKE1("PassengerAppEnv",
	(Take1Func) cmd_passenger_app_env,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"The environment under which applications are run."),
AP_INIT_TAKE1("PassengerAppGroupName",
	(Take1Func) cmd_passenger_app_group_name,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"Application process group name."),
AP_INIT_TAKE1("PassengerAppLogFile",
	(Take1Func) cmd_passenger_enterprise_only,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"Application log file path."),
AP_INIT_TAKE1("PassengerAppRoot",
	(Take1Func) cmd_passenger_app_root,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"The application's root directory."),
AP_INIT_TAKE1("PassengerAppType",
	(Take1Func) cmd_passenger_app_type,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"Force specific application type."),
AP_INIT_TAKE1("PassengerBaseURI",
	(Take1Func) cmd_passenger_base_uri,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"Declare the given base URI as belonging to a web application."),
AP_INIT_FLAG("PassengerBufferResponse",
	(FlagFunc) cmd_passenger_buffer_response,
	NULL,
	RSRC_CONF | ACCESS_CONF | OR_ALL,
	"Whether to enable extra response buffering inside Apache."),
AP_INIT_FLAG("PassengerBufferUpload",
	(FlagFunc) cmd_passenger_buffer_upload,
	NULL,
	RSRC_CONF | ACCESS_CONF | OR_ALL,
	"Whether to buffer file uploads."),
AP_INIT_TAKE1("PassengerConcurrencyModel",
	(Take1Func) cmd_passenger_enterprise_only,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"The concurrency model that should be used for applications."),
AP_INIT_TAKE2("PassengerCtl",
	(Take2Func) cmd_passenger_ctl,
	NULL,
	RSRC_CONF,
	"Set advanced Phusion Passenger options."),
AP_INIT_TAKE1("PassengerDataBufferDir",
	(Take1Func) cmd_passenger_data_buffer_dir,
	NULL,
	RSRC_CONF,
	"The directory that Phusion Passenger data buffers should be stored into."),
AP_INIT_TAKE1("PassengerDebugLogFile",
	(Take1Func) cmd_passenger_log_file,
	NULL,
	RSRC_CONF,
	"The Phusion Passenger log file."),
AP_INIT_FLAG("PassengerDebugger",
	(FlagFunc) cmd_passenger_enterprise_only,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"Whether to turn on debugger support"),
AP_INIT_TAKE1("PassengerDefaultGroup",
	(Take1Func) cmd_passenger_default_group,
	NULL,
	RSRC_CONF,
	"The group that Phusion Passenger applications must run as when user switching fails or is disabled."),
AP_INIT_TAKE1("PassengerDefaultRuby",
	(Take1Func) cmd_passenger_default_ruby,
	NULL,
	RSRC_CONF,
	"Phusion Passenger's default Ruby interpreter to use."),
AP_INIT_TAKE1("PassengerDefaultUser",
	(Take1Func) cmd_passenger_default_user,
	NULL,
	RSRC_CONF,
	"The user that Phusion Passenger applications must run as when user switching fails or is disabled."),
AP_INIT_FLAG("PassengerDisableSecurityUpdateCheck",
	(FlagFunc) cmd_passenger_disable_security_update_check,
	NULL,
	RSRC_CONF,
	"Whether to disable the Phusion Passenger security update check & notification."),
AP_INIT_TAKE1("PassengerDumpConfigManifest",
	(Take1Func) cmd_passenger_dump_config_manifest,
	NULL,
	RSRC_CONF,
	"Dump the Passenger config manifest to the given file, for debugging purposes."),
AP_INIT_FLAG("PassengerEnabled",
	(FlagFunc) cmd_passenger_enabled,
	NULL,
	RSRC_CONF | ACCESS_CONF | OR_ALL,
	"Enable or disable Phusion Passenger."),
AP_INIT_FLAG("PassengerErrorOverride",
	(FlagFunc) cmd_passenger_error_override,
	NULL,
	RSRC_CONF | ACCESS_CONF | OR_ALL,
	"Allow Apache to handle error response."),
AP_INIT_TAKE1("PassengerFileDescriptorLogFile",
	(Take1Func) cmd_passenger_file_descriptor_log_file,
	NULL,
	RSRC_CONF,
	"The Phusion Passenger file descriptor log file."),
AP_INIT_TAKE1("PassengerFlyWith",
	(Take1Func) cmd_passenger_enterprise_only,
	NULL,
	RSRC_CONF,
	"Use Flying Passenger"),
AP_INIT_TAKE1("PassengerForceMaxConcurrentRequestsPerProcess",
	(Take1Func) cmd_passenger_force_max_concurrent_requests_per_process,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"Force Passenger to believe that an application process can handle the given number of concurrent requests per process"),
AP_INIT_FLAG("PassengerFriendlyErrorPages",
	(FlagFunc) cmd_passenger_friendly_error_pages,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"Whether to display friendly error pages when something goes wrong."),
AP_INIT_TAKE1("PassengerGroup",
	(Take1Func) cmd_passenger_group,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"The group that Ruby applications must run as."),
AP_INIT_FLAG("PassengerHighPerformance",
	(FlagFunc) cmd_passenger_high_performance,
	NULL,
	RSRC_CONF | ACCESS_CONF | OR_ALL,
	"Enable or disable Passenger's high performance mode."),
AP_INIT_TAKE1("PassengerInstanceRegistryDir",
	(Take1Func) cmd_passenger_instance_registry_dir,
	NULL,
	RSRC_CONF,
	"The directory to register the Phusion Passenger instance to."),
AP_INIT_FLAG("PassengerLoadShellEnvvars",
	(FlagFunc) cmd_passenger_load_shell_envvars,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"Whether to load environment variables from the shell before running the application."),
AP_INIT_TAKE1("PassengerLogFile",
	(Take1Func) cmd_passenger_log_file,
	NULL,
	RSRC_CONF,
	"The Phusion Passenger log file."),
AP_INIT_TAKE1("PassengerLogLevel",
	(Take1Func) cmd_passenger_log_level,
	NULL,
	RSRC_CONF,
	"The Phusion Passenger log verbosity."),
AP_INIT_TAKE1("PassengerLveMinUid",
	(Take1Func) cmd_passenger_lve_min_uid,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"Minimum user ID starting from which entering LVE and CageFS is allowed."),
AP_INIT_TAKE1("PassengerMaxInstances",
	(Take1Func) cmd_passenger_enterprise_only,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"The maximum number of instances for the current application that Phusion Passenger may spawn."),
AP_INIT_TAKE1("PassengerMaxInstancesPerApp",
	(Take1Func) cmd_passenger_max_instances_per_app,
	NULL,
	RSRC_CONF,
	"The maximum number of simultaneously alive application instances a single application may occupy."),
AP_INIT_TAKE1("PassengerMaxPoolSize",
	(Take1Func) cmd_passenger_max_pool_size,
	NULL,
	RSRC_CONF,
	"The maximum number of simultaneously alive application processes."),
AP_INIT_TAKE1("PassengerMaxPreloaderIdleTime",
	(Take1Func) cmd_passenger_max_preloader_idle_time,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"The maximum number of seconds that a preloader process may be idle before it is shutdown."),
AP_INIT_TAKE1("PassengerMaxRequestQueueSize",
	(Take1Func) cmd_passenger_max_request_queue_size,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"The maximum number of queued requests."),
AP_INIT_TAKE1("PassengerMaxRequestQueueTime",
	(Take1Func) cmd_passenger_enterprise_only,
	NULL,
	RSRC_CONF | ACCESS_CONF | OR_ALL,
	"The maximum number of seconds that a request may remain in the queue before it is dropped."),
AP_INIT_TAKE1("PassengerMaxRequestTime",
	(Take1Func) cmd_passenger_enterprise_only,
	NULL,
	RSRC_CONF | ACCESS_CONF | OR_ALL,
	"The maximum time (in seconds) that the current application may spend on a request."),
AP_INIT_TAKE1("PassengerMaxRequests",
	(Take1Func) cmd_passenger_max_requests,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"The maximum number of requests that an application instance may process."),
AP_INIT_TAKE1("PassengerMemoryLimit",
	(Take1Func) cmd_passenger_enterprise_only,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"The maximum amount of memory in MB that an application instance may use."),
AP_INIT_TAKE1("PassengerMeteorAppSettings",
	(Take1Func) cmd_passenger_meteor_app_settings,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"Settings file for (non-bundled) Meteor apps."),
AP_INIT_TAKE1("PassengerMinInstances",
	(Take1Func) cmd_passenger_min_instances,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"The minimum number of application instances to keep when cleaning idle instances."),
AP_INIT_TAKE1("PassengerMonitorLogFile",
	(Take1Func) cmd_passenger_monitor_log_file,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"Log file path to monitor."),
AP_INIT_TAKE1("PassengerNodejs",
	(Take1Func) cmd_passenger_nodejs,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"The Node.js command to use."),
AP_INIT_TAKE1("PassengerPoolIdleTime",
	(Take1Func) cmd_passenger_pool_idle_time,
	NULL,
	RSRC_CONF,
	"The maximum number of seconds that an application may be idle before it gets terminated."),
AP_INIT_TAKE1("PassengerPreStart",
	(Take1Func) cmd_passenger_pre_start,
	NULL,
	RSRC_CONF,
	"Prestart the given web applications during startup."),
AP_INIT_TAKE1("PassengerPython",
	(Take1Func) cmd_passenger_python,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"The Python interpreter to use."),
AP_INIT_FLAG("PassengerResistDeploymentErrors",
	(FlagFunc) cmd_passenger_enterprise_only,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"Whether to turn on deployment error resistance."),
AP_INIT_TAKE1("PassengerResponseBufferHighWatermark",
	(Take1Func) cmd_passenger_response_buffer_high_watermark,
	NULL,
	RSRC_CONF,
	"The maximum size of the Phusion Passenger response buffer."),
AP_INIT_TAKE1("PassengerRestartDir",
	(Take1Func) cmd_passenger_restart_dir,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"The directory in which Phusion Passenger should look for restart.txt."),
AP_INIT_FLAG("PassengerRollingRestarts",
	(FlagFunc) cmd_passenger_enterprise_only,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"Whether to turn on rolling restarts."),
AP_INIT_TAKE1("PassengerRoot",
	(Take1Func) cmd_passenger_root,
	NULL,
	RSRC_CONF,
	"The Phusion Passenger root folder."),
AP_INIT_TAKE1("PassengerRuby",
	(Take1Func) cmd_passenger_ruby,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"The Ruby interpreter to use."),
AP_INIT_TAKE1("PassengerSecurityUpdateCheckProxy",
	(Take1Func) cmd_passenger_security_update_check_proxy,
	NULL,
	RSRC_CONF,
	"Use specified HTTP/SOCKS proxy for the Phusion Passenger security update check."),
AP_INIT_FLAG("PassengerShowVersionInHeader",
	(FlagFunc) cmd_passenger_show_version_in_header,
	NULL,
	RSRC_CONF,
	"Whether to show the Phusion Passenger version number in the X-Powered-By header."),
AP_INIT_TAKE1("PassengerSocketBacklog",
	(Take1Func) cmd_passenger_socket_backlog,
	NULL,
	RSRC_CONF,
	"The Phusion Passenger socket backlog."),
AP_INIT_TAKE1("PassengerSpawnMethod",
	(Take1Func) cmd_passenger_spawn_method,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"The spawn method to use."),
AP_INIT_TAKE1("PassengerStartTimeout",
	(Take1Func) cmd_passenger_start_timeout,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"A timeout for application startup."),
AP_INIT_TAKE1("PassengerStartupFile",
	(Take1Func) cmd_passenger_startup_file,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"Force specific startup file."),
AP_INIT_TAKE1("PassengerStatThrottleRate",
	(Take1Func) cmd_passenger_stat_throttle_rate,
	NULL,
	RSRC_CONF,
	"Limit the number of stat calls to once per given seconds."),
AP_INIT_FLAG("PassengerStickySessions",
	(FlagFunc) cmd_passenger_sticky_sessions,
	NULL,
	RSRC_CONF | ACCESS_CONF | OR_ALL,
	"Whether to enable sticky sessions."),
AP_INIT_TAKE1("PassengerStickySessionsCookieName",
	(Take1Func) cmd_passenger_sticky_sessions_cookie_name,
	NULL,
	RSRC_CONF | ACCESS_CONF | OR_ALL,
	"The cookie name to use for sticky sessions."),
AP_INIT_TAKE1("PassengerThreadCount",
	(Take1Func) cmd_passenger_enterprise_only,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"The number of threads that Phusion Passenger should spawn per application."),
AP_INIT_FLAG("PassengerTurbocaching",
	(FlagFunc) cmd_passenger_turbocaching,
	NULL,
	RSRC_CONF,
	"Whether to enable turbocaching in Phusion Passenger."),
AP_INIT_FLAG("PassengerUseGlobalQueue",
	(FlagFunc) cmd_passenger_use_global_queue,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"Obsolete option."),
AP_INIT_TAKE1("PassengerUser",
	(Take1Func) cmd_passenger_user,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"The user that Ruby applications must run as."),
AP_INIT_FLAG("PassengerUserSwitching",
	(FlagFunc) cmd_passenger_user_switching,
	NULL,
	RSRC_CONF,
	"Whether to enable user switching support in Phusion Passenger."),
AP_INIT_TAKE1("RackBaseURI",
	(Take1Func) cmd_passenger_base_uri,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"Declare the given base URI as belonging to a web application."),
AP_INIT_TAKE1("RackEnv",
	(Take1Func) cmd_passenger_app_env,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"The environment under which applications are run."),
AP_INIT_FLAG("RailsAllowModRewrite",
	(FlagFunc) cmd_rails_allow_mod_rewrite,
	NULL,
	RSRC_CONF,
	"Obsolete option."),
AP_INIT_TAKE1("RailsAppSpawnerIdleTime",
	(Take1Func) cmd_passenger_max_preloader_idle_time,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"The maximum number of seconds that a preloader process may be idle before it is shutdown."),
AP_INIT_TAKE1("RailsBaseURI",
	(Take1Func) cmd_passenger_base_uri,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"Declare the given base URI as belonging to a web application."),
AP_INIT_TAKE1("RailsDefaultUser",
	(Take1Func) cmd_passenger_default_user,
	NULL,
	RSRC_CONF,
	"The user that Phusion Passenger applications must run as when user switching fails or is disabled."),
AP_INIT_TAKE1("RailsEnv",
	(Take1Func) cmd_passenger_app_env,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"The environment under which applications are run."),
AP_INIT_TAKE1("RailsFrameworkSpawnerIdleTime",
	(Take1Func) cmd_rails_framework_spawner_idle_time,
	NULL,
	RSRC_CONF,
	"Obsolete option."),
AP_INIT_TAKE1("RailsMaxInstancesPerApp",
	(Take1Func) cmd_passenger_max_instances_per_app,
	NULL,
	RSRC_CONF,
	"The maximum number of simultaneously alive application instances a single application may occupy."),
AP_INIT_TAKE1("RailsMaxPoolSize",
	(Take1Func) cmd_passenger_max_pool_size,
	NULL,
	RSRC_CONF,
	"The maximum number of simultaneously alive application processes."),
AP_INIT_TAKE1("RailsPoolIdleTime",
	(Take1Func) cmd_passenger_pool_idle_time,
	NULL,
	RSRC_CONF,
	"The maximum number of seconds that an application may be idle before it gets terminated."),
AP_INIT_TAKE1("RailsRuby",
	(Take1Func) cmd_passenger_ruby,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"The Ruby interpreter to use."),
AP_INIT_TAKE1("RailsSpawnMethod",
	(Take1Func) cmd_passenger_spawn_method,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"The spawn method to use."),
AP_INIT_TAKE1("RailsSpawnServer",
	(Take1Func) cmd_rails_spawn_server,
	NULL,
	RSRC_CONF,
	"Obsolete option."),
AP_INIT_FLAG("RailsUserSwitching",
	(FlagFunc) cmd_passenger_user_switching,
	NULL,
	RSRC_CONF,
	"Whether to enable user switching support in Phusion Passenger."),
AP_INIT_TAKE1("UnionStationFilter",
	(Take1Func) cmd_union_station_filter,
	NULL,
	RSRC_CONF | ACCESS_CONF | OR_OPTIONS,
	"Obsolete option."),
AP_INIT_TAKE1("UnionStationGatewayAddress",
	(Take1Func) cmd_union_station_gateway_address,
	NULL,
	RSRC_CONF,
	"Obsolete option."),
AP_INIT_TAKE1("UnionStationGatewayCert",
	(Take1Func) cmd_union_station_gateway_cert,
	NULL,
	RSRC_CONF,
	"Obsolete option."),
AP_INIT_TAKE1("UnionStationGatewayPort",
	(Take1Func) cmd_union_station_gateway_port,
	NULL,
	RSRC_CONF,
	"Obsolete option."),
AP_INIT_TAKE1("UnionStationKey",
	(Take1Func) cmd_union_station_key,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"Obsolete option."),
AP_INIT_TAKE1("UnionStationProxyAddress",
	(Take1Func) cmd_union_station_proxy_address,
	NULL,
	RSRC_CONF,
	"Obsolete option."),
AP_INIT_FLAG("UnionStationSupport",
	(FlagFunc) cmd_union_station_support,
	NULL,
	RSRC_CONF | ACCESS_CONF,
	"Obsolete option."),
