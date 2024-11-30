// File generated from our OpenAPI spec by Stainless. See CONTRIBUTING.md for details.

import { type Agent } from './_shims/index';
import * as Core from './core';
import {
    Completion,
    CompletionChoice,
    CompletionCreateParams,
    CompletionCreateParamsNonStreaming,
    CompletionCreateParamsStreaming,
    CompletionUsage,
    Completions,
} from './resources/completions';

import { Chat, ChatModel } from './resources/chat/chat';
import {
    ChatCompletion,
    ChatCompletionAssistantMessageParam,
    ChatCompletionAudio,
    ChatCompletionAudioParam,
    ChatCompletionChunk,
    ChatCompletionContentPart,
    ChatCompletionContentPartImage,
    ChatCompletionContentPartInputAudio,
    ChatCompletionContentPartRefusal,
    ChatCompletionContentPartText,
    ChatCompletionCreateParams,
    ChatCompletionCreateParamsNonStreaming,
    ChatCompletionCreateParamsStreaming,
    ChatCompletionFunctionCallOption,
    ChatCompletionFunctionMessageParam,
    ChatCompletionMessage,
    ChatCompletionMessageParam,
    ChatCompletionMessageToolCall,
    ChatCompletionModality,
    ChatCompletionNamedToolChoice,
    ChatCompletionPredictionContent,
    ChatCompletionRole,
    ChatCompletionStreamOptions,
    ChatCompletionSystemMessageParam,
    ChatCompletionTokenLogprob,
    ChatCompletionTool,
    ChatCompletionToolChoiceOption,
    ChatCompletionToolMessageParam,
    ChatCompletionUserMessageParam,
} from './resources/chat/completions';


export interface ClientOptions {
    /**
     * Defaults to process.env['OPENAI_API_KEY'].
     */
    apiKey?: string | undefined;

    /**
     * Defaults to process.env['OPENAI_ORG_ID'].
     */
    organization?: string | null | undefined;

    /**
     * Defaults to process.env['OPENAI_PROJECT_ID'].
     */
    project?: string | null | undefined;

    /**
     * Override the default base URL for the API, e.g., "https://api.example.com/v2/"
     *
     * Defaults to process.env['OPENAI_BASE_URL'].
     */
    baseURL?: string | null | undefined;

    /**
     * The maximum amount of time (in milliseconds) that the client should wait for a response
     * from the server before timing out a single request.
     *
     * Note that request timeouts are retried by default, so in a worst-case scenario you may wait
     * much longer than this timeout before the promise succeeds or fails.
     */
    timeout?: number;

    /**
     * An HTTP agent used to manage HTTP(S) connections.
     *
     * If not provided, an agent will be constructed by default in the Node.js environment,
     * otherwise no agent is used.
     */
    httpAgent?: Agent;

    /**
     * Specify a custom `fetch` function implementation.
     *
     * If not provided, we use `node-fetch` on Node.js and otherwise expect that `fetch` is
     * defined globally.
     */
    fetch?: Core.Fetch | undefined;

    /**
     * The maximum number of times that the client will retry a request in case of a
     * temporary failure, like a network error or a 5XX error from the server.
     *
     * @default 2
     */
    maxRetries?: number;

    /**
     * Default headers to include with every request to the API.
     *
     * These can be removed in individual requests by explicitly setting the
     * header to `undefined` or `null` in request options.
     */
    defaultHeaders?: Core.Headers;

    /**
     * Default query parameters to include with every request to the API.
     *
     * These can be removed in individual requests by explicitly setting the
     * param to `undefined` in request options.
     */
    defaultQuery?: Core.DefaultQuery;

    /**
     * By default, client-side use of this library is not allowed, as it risks exposing your secret API credentials to attackers.
     * Only set this option to `true` if you understand the risks and have appropriate mitigations in place.
     */
    dangerouslyAllowBrowser?: boolean;
}

OpenAINamespace.Chat = Chat;

export declare namespace OpenAINamespace {
    export {
        Completions as Completions,
        type Completion as Completion,
        type CompletionChoice as CompletionChoice,
        type CompletionUsage as CompletionUsage,
        type CompletionCreateParams as CompletionCreateParams,
        type CompletionCreateParamsNonStreaming as CompletionCreateParamsNonStreaming,
        type CompletionCreateParamsStreaming as CompletionCreateParamsStreaming,
    };

    export {
        Chat as Chat,
        type ChatModel as ChatModel,
        type ChatCompletion as ChatCompletion,
        type ChatCompletionAssistantMessageParam as ChatCompletionAssistantMessageParam,
        type ChatCompletionAudio as ChatCompletionAudio,
        type ChatCompletionAudioParam as ChatCompletionAudioParam,
        type ChatCompletionChunk as ChatCompletionChunk,
        type ChatCompletionContentPart as ChatCompletionContentPart,
        type ChatCompletionContentPartImage as ChatCompletionContentPartImage,
        type ChatCompletionContentPartInputAudio as ChatCompletionContentPartInputAudio,
        type ChatCompletionContentPartRefusal as ChatCompletionContentPartRefusal,
        type ChatCompletionContentPartText as ChatCompletionContentPartText,
        type ChatCompletionFunctionCallOption as ChatCompletionFunctionCallOption,
        type ChatCompletionFunctionMessageParam as ChatCompletionFunctionMessageParam,
        type ChatCompletionMessage as ChatCompletionMessage,
        type ChatCompletionMessageParam as ChatCompletionMessageParam,
        type ChatCompletionMessageToolCall as ChatCompletionMessageToolCall,
        type ChatCompletionModality as ChatCompletionModality,
        type ChatCompletionNamedToolChoice as ChatCompletionNamedToolChoice,
        type ChatCompletionPredictionContent as ChatCompletionPredictionContent,
        type ChatCompletionRole as ChatCompletionRole,
        type ChatCompletionStreamOptions as ChatCompletionStreamOptions,
        type ChatCompletionSystemMessageParam as ChatCompletionSystemMessageParam,
        type ChatCompletionTokenLogprob as ChatCompletionTokenLogprob,
        type ChatCompletionTool as ChatCompletionTool,
        type ChatCompletionToolChoiceOption as ChatCompletionToolChoiceOption,
        type ChatCompletionToolMessageParam as ChatCompletionToolMessageParam,
        type ChatCompletionUserMessageParam as ChatCompletionUserMessageParam,
        type ChatCompletionCreateParams as ChatCompletionCreateParams,
        type ChatCompletionCreateParamsNonStreaming as ChatCompletionCreateParamsNonStreaming,
        type ChatCompletionCreateParamsStreaming as ChatCompletionCreateParamsStreaming,
    };


}

// ---------------------- Azure ----------------------

/** API Client for interfacing with the Azure OpenAI API. */
export interface AzureClientOptions extends ClientOptions {
    /**
     * Defaults to process.env['OPENAI_API_VERSION'].
     */
    apiVersion?: string | undefined;

    /**
     * Your Azure endpoint, including the resource, e.g. `https://example-resource.azure.openai.com/`
     */
    endpoint?: string | undefined;

    /**
     * A model deployment, if given, sets the base client URL to include `/deployments/{deployment}`.
     * Note: this means you won't be able to use non-deployment endpoints. Not supported with Assistants APIs.
     */
    deployment?: string | undefined;

    /**
     * Defaults to process.env['AZURE_OPENAI_API_KEY'].
     */
    apiKey?: string | undefined;

    /**
     * A function that returns an access token for Microsoft Entra (formerly known as Azure Active Directory),
     * which will be invoked on every request.
     */
    azureADTokenProvider?: (() => Promise<string>) | undefined;
}


// ---------------------- End Azure ----------------------


export default OpenAINamespace;
