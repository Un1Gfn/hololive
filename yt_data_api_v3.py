#!/bin/python3

# https://developers.google.com/youtube/v3/docs/videos/list

import os

import google.auth.transport.requests
import google.oauth2.credentials
import google_auth_oauthlib.flow
import googleapiclient.discovery
import googleapiclient.errors

SCOPES = ["https://www.googleapis.com/auth/youtube.readonly"]
CREDENTIAL = "/home/darren/hololive/credentials.json"
TOKEN =  "/home/darren/hololive/token.json"
ANN = "coYw-eVU0Ks"
TVBS = "2mCSYvcfhtc"


# get credentials and create an API client
# https://developers.google.com/tasks/setup#python
# https://developers.google.com/tasks/quickstart/python#step_2_configure_the_sample
def build():

    creds = None

    if os.path.exists('token.json'):
        creds = google.oauth2.credentials.Credentials.from_authorized_user_file(TOKEN, SCOPES)

    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(google.auth.transport.requests.Request())
        else:
            flow = google_auth_oauthlib.flow.InstalledAppFlow.from_client_secrets_file(CREDENTIAL, SCOPES)
            creds = flow.run_local_server(port=0)
        # Save the credentials for the next run
        with open(TOKEN, 'w') as token:
            token.write(creds.to_json())

    return googleapiclient.discovery.build("youtube", "v3", credentials=creds)


def main():

    youtube = build()

    request = youtube.videos().list(
        part="snippet,contentDetails,statistics",
        # id=ANN
        id=TVBS
    )

    response = request.execute()

    print(response)

if __name__ == "__main__":
    main()
