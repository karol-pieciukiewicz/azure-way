using System.Threading;
using System.Diagnostics;
using System.Collections;
using System;
using Azure.Identity;
using Azure.Messaging.ServiceBus;
using System.Linq;

string connectionString = Environment.GetEnvironmentVariable("serviceBusConnectionString") ?? throw new ArgumentNullException();
string queueNames = Environment.GetEnvironmentVariable("serviceBusQueues") ?? throw new ArgumentNullException();
int messagesToAdd = int.Parse(Environment.GetEnvironmentVariable("messageCount") ?? "1000");

await using var client = new ServiceBusClient(connectionString);

var packageSize = 1000;
IEnumerable<int> messages = Enumerable.Range(0, messagesToAdd);

var queueNamesArray = queueNames.Split("|");
foreach (var queueName in queueNamesArray){
    Console.WriteLine($"start adding for: {queueName}");
    // create the sender
    ServiceBusSender sender = client.CreateSender(queueName);

    var i = 1;
    var chunks = messages.Chunk(packageSize);

    Stopwatch stopwatchGlobal = Stopwatch.StartNew();
    Stopwatch stopwatch= Stopwatch.StartNew();

    foreach (var chunk in chunks)
    {
        var brokeredMessages = chunk.Select(m => new ServiceBusMessage(m.ToString()));
        await sender.SendMessagesAsync(brokeredMessages);
        Console.WriteLine($"added {i*packageSize} messages");
        Console.WriteLine($"time: {stopwatch.Elapsed}");
        stopwatch= Stopwatch.StartNew();

        i++;
    }

    stopwatch.Stop();
    stopwatchGlobal.Stop();
    Console.WriteLine($"time: {stopwatchGlobal.Elapsed}");
}