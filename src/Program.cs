using System.Configuration;
using Azure;
using Azure.Identity;
using Azure.Storage.Blobs;
using Azure.Storage.Blobs.ChangeFeed;

var config =
    ConfigurationManager.OpenExeConfiguration
        (ConfigurationUserLevel.None);

async Task ChangeFeedStreamAsync
    (BlobServiceClient blobServiceClient, int waitTimeMs, string? cursor, CancellationToken ct)
{
    // Get a new change feed client.
    BlobChangeFeedClient changeFeedClient = blobServiceClient.GetChangeFeedClient();

    DateTime previous = DateTime.Now;
    while (!ct.IsCancellationRequested)
    {
        IAsyncEnumerator<Page<BlobChangeFeedEvent>> enumerator = changeFeedClient
            .GetChangesAsync(continuationToken: cursor).AsPages().GetAsyncEnumerator(ct);

        int eventsInBatch = 0;
        while (!ct.IsCancellationRequested)
        {
            var result = await enumerator.MoveNextAsync();
            int eventsInPage = 0;

            if (result)
            {
                foreach (var changeFeedEvent in enumerator.Current.Values)
                {
                    eventsInPage++;
                    string subject = changeFeedEvent.Subject;
                    string eventType = changeFeedEvent.EventType.ToString();

                    // Console.WriteLine("Subject: " + subject + "\n" +
                    //                   "Event Type: " + eventType + "\n" +
                    //                   "Api: " + "");
                }

                // helper method to save cursor. 
                cursor = enumerator.Current.ContinuationToken;
                SaveCursor(cursor);
            }
            else
            {
                break;
            }

            eventsInBatch += eventsInPage;
            Console.WriteLine("Processing [" + eventsInBatch + " events in batch] [Rate: " +
                              (eventsInPage * 1f / (DateTime.Now - previous).TotalSeconds) + " events/s]");
            previous = DateTime.Now;
        }

        if (eventsInBatch == 0)
        {
            Console.WriteLine("Waiting " + waitTimeMs + " ms");
            await Task.Delay(waitTimeMs, ct);
        }
    }
}

void SaveCursor(string? cursor)
{
    Console.WriteLine("New Cursor: " + cursor);

    config.AppSettings.Settings.Clear();
    config.AppSettings.Settings.Add("Cursor", cursor);
    config.Save(ConfigurationSaveMode.Modified);
}

if (args.Length != 1)
{
    Console.WriteLine("Usage: ReadChangeFeed https://STORAGE_ACCOUNT_NAME.blob.core.windows.net/");
}

var azureCliCredential = new AzureCliCredential();
var blobServiceClient = new BlobServiceClient(
    new Uri(args[0]),
    azureCliCredential);

var keyValueConfigurationElement = config.AppSettings.Settings["Cursor"];
await ChangeFeedStreamAsync(blobServiceClient, 60000, keyValueConfigurationElement?.Value, CancellationToken.None);
