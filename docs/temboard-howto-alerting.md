!!! note

    `alerting` is part of the `monitoring` plugin. This means that you need
    to activate the `monitoring` plugin in order to take advantage of `alerting`.

temBoard watch monitoring metrics and can alert you
if a metrics hit two different threshold : a warning threshold and a critical threshold.
temBoard notifies you using mail or SMS (through Twilio messaging service).


## In dashboard

When activated, `alerting` can show some information on the dashboard page.

On left side, the current status of metrics configured for alerting.
On right side, the list of 20 alerts.

![Alerting in dashboard](sc/alerting_dashboard.png)

temBoard updates statuses and alerts every minute to match the last check.


## Detailed Statuses

The status page shows all monitored probes in a more detailed view.

![Alerting probes](sc/alerting_checks.png)

## Status Over Time

By clicking on probe name, one can also access an even more detailed
view for each probe. In this view, users will find:

 - the current status,
 - the thresholds values over time,
 - the values for the monitored probe over time,
 - the past alerts (ie. status change),
 - the time ranges for which the status was `warning` or `critical` or if the
     check was disabled.

![Alerting probe detail](sc/alerting_check.png)

On this page, user can enable/disable the checks and configure the thresholds.
Please beware that the thresholds are configured per instance.

![Alerting editing](sc/alerting_edit.png)

## Auto-refresh

Every alerting pages refreshes data every minute to present the latest checks.

## Notifications

temBoard is able to send a notification (Email or SMS) when the status for
a metric on an instance changes.


### Sending

First of all transport systems (SMTP or SMS Twilio service) need to be
configured.

In your `temBoard` configuration file you need to add the following section:

```yaml
[notifications]
# SMTP host
smtp_host = smtp.gmail.com
# SMTP port
smtp_port = 465
smtp_tls = True
smtp_login = <email>@gmail.com
smtp_password = <password>

# Twilio SMS service configuration
twilio_account_sid = <account_id>
twilio_auth_token = <auth_token>
twilio_from = <from_number>
```

Note: you can leave the settings commented if you don't want to use them.

The above example shows how to configure the SMTP for sending emails via Google
Mail. The password may be an application password in case you're using
2-Step-Verification. See [Sign in using App
Passwords](https://support.google.com/accounts/answer/185833).

If you use your own SMTP service, you may also want to set the sender FROM address:
```yaml
smtp_from_addr = <email>@mydomain.com
```

For the twilio settings, please refer to [Twilio Usage Documentation](https://www.twilio.com/docs/usage).

Once the configuration seem to be OK, admin users can send test mails or SMS by
clicking on the dedicated buttons in the `Alert notifications` tab.

![Alerting notification test](sc/alerting_notification_test.png)

### Enabling

In order to get notified, admin users have to set an *Email* or *Phone number*
to the users.

![Alerting notification set user](sc/alerting_notification_set_user.png)

You must also turn on notification at the instance level.

![Alerting notification set instance](sc/alerting_notification_set_instance.png)
