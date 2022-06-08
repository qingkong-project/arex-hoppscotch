<template>
<div>
  <Splitpanes
    class="smart-splitter"
    :rtl="SIDEBAR_ON_LEFT && windowInnerWidth.x.value >= 768"
    :class="{
      '!flex-row-reverse': SIDEBAR_ON_LEFT && windowInnerWidth.x.value >= 768,
    }"
    :horizontal="!(windowInnerWidth.x.value >= 768)"
  >



    <Pane size="10" style="margin: 10px">
      <div class="relative flex">
        <label for="method">
          <tippy
            ref="methodOptions"
            interactive
            trigger="click"
            theme="popover"
            arrow
          >
            <template #trigger>
              <span class="select-wrapper">
                <input
                  id="method"
                  class="flex px-4 py-2 font-semibold border rounded-l cursor-pointer bg-primaryLight border-divider text-secondaryDark w-32 hover:border-dividerDark focus-visible:bg-transparent focus-visible:border-dividerDark"
                  :value="arexType"
                  :readonly="true"
                  :placeholder="'ssss'"
                />
              </span>
            </template>
            <SmartItem
              v-for="(method, index) in arexTypes"
              :key="`method-${index}`"
              :label="method"
              @click.native="onSelectArexType(method)"
            />
          </tippy>
        </label>
      </div>
    </Pane>

    <Pane size="30">
      <Splitpanes class="smart-splitter" :horizontal="COLUMN_LAYOUT">
        <Pane
          :size="COLUMN_LAYOUT ? 45 : 50"
          class="hide-scrollbar !overflow-auto"
        >
          <HttpRequest />
          <SmartTabs styles="sticky bg-primary top-upperPrimaryStickyFold z-10">
            <SmartTab
              :id="'params'"
              :label="`${$t('tab.parameters')}`"
              :selected="true"
              :info="`${newActiveParamsCount$}`"
            >
              <HttpParameters />
            </SmartTab>

            <SmartTab :id="'bodyParams'" :label="`${$t('tab.body')}`">
              <HttpBody />
            </SmartTab>

            <SmartTab
              :id="'headers'"
              :label="`${$t('tab.headers')}`"
              :info="`${newActiveHeadersCount$}`"
            >
              <HttpHeaders />
            </SmartTab>

            <SmartTab
              :id="'authorization'"
              :label="`${$t('tab.authorization')}`"
            >
              <HttpAuthorization />
            </SmartTab>

            <SmartTab
              :id="'preRequestScript'"
              :label="`${$t('tab.pre_request_script')}`"
              :indicator="
                preRequestScript && preRequestScript.length > 0 ? true : false
              "
            >
              <HttpPreRequestScript />
            </SmartTab>

            <SmartTab
              :id="'tests'"
              :label="`${$t('tab.tests')}`"
              :indicator="testScript && testScript.length > 0 ? true : false"
            >
              <HttpTests />
            </SmartTab>
          </SmartTabs>
        </Pane>
        <Pane
          :size="COLUMN_LAYOUT ? 65 : 50"
          class="flex flex-col hide-scrollbar !overflow-auto"
        >
          <HttpResponse ref="response" />
        </Pane>
      </Splitpanes>
    </Pane>
    <Pane size="30" v-if="arexType==='比对接口测试'">
      <Splitpanes class="smart-splitter" :horizontal="COLUMN_LAYOUT">
        <Pane
          :size="COLUMN_LAYOUT ? 45 : 50"
          class="hide-scrollbar !overflow-auto"
        >
          <HttpRequest />
          <SmartTabs styles="sticky bg-primary top-upperPrimaryStickyFold z-10">
            <SmartTab
              :id="'params'"
              :label="`${$t('tab.parameters')}`"
              :selected="true"
              :info="`${newActiveParamsCount$}`"
            >
              <HttpParameters />
            </SmartTab>

            <SmartTab :id="'bodyParams'" :label="`${$t('tab.body')}`">
              <HttpBody />
            </SmartTab>

            <SmartTab
              :id="'headers'"
              :label="`${$t('tab.headers')}`"
              :info="`${newActiveHeadersCount$}`"
            >
              <HttpHeaders />
            </SmartTab>

            <SmartTab
              :id="'authorization'"
              :label="`${$t('tab.authorization')}`"
            >
              <HttpAuthorization />
            </SmartTab>

            <SmartTab
              :id="'preRequestScript'"
              :label="`${$t('tab.pre_request_script')}`"
              :indicator="
                preRequestScript && preRequestScript.length > 0 ? true : false
              "
            >
              <HttpPreRequestScript />
            </SmartTab>

            <SmartTab
              :id="'tests'"
              :label="`${$t('tab.tests')}`"
              :indicator="testScript && testScript.length > 0 ? true : false"
            >
              <HttpTests />
            </SmartTab>
          </SmartTabs>
        </Pane>
        <Pane
          :size="COLUMN_LAYOUT ? 65 : 50"
          class="flex flex-col hide-scrollbar !overflow-auto"
        >
          <HttpResponse ref="response" />
        </Pane>
      </Splitpanes>
    </Pane>



    <Pane
      v-if="SIDEBAR"
      size="25"
      min-size="20"
      class="hide-scrollbar !overflow-auto"
    >
      <SmartTabs styles="sticky bg-primary z-10 top-0" vertical>
        <SmartTab
          :id="'collections'"
          icon="folder"
          :label="`${$t('tab.collections')}`"
          :selected="true"
        >
          <Collections />
        </SmartTab>
        <SmartTab
          :id="'history'"
          icon="clock"
          :label="`${$t('tab.history')}`"
        >
          <History ref="historyComponent" :page="'rest'" />
        </SmartTab>



        <SmartTab
          :id="'env'"
          icon="layers"
          :label="`${$t('environment.title')}`"
        >
          <Environments />
        </SmartTab>
      </SmartTabs>
    </Pane>
    <SmartConfirmModal
      :show="confirmSync"
      :title="`${$t('confirm.sync')}`"
      @hide-modal="confirmSync = false"
      @resolve="syncRequest"
    />
  </Splitpanes>
</div>
</template>

<script lang="ts">
import {
  defineComponent,
  onBeforeMount,
  onBeforeUnmount,
  onMounted,
  Ref,
  ref,
  useContext,
} from "@nuxtjs/composition-api"
import { Splitpanes, Pane } from "splitpanes"
import "splitpanes/dist/splitpanes.css"
import { map } from "rxjs/operators"
import { Subscription } from "rxjs"
import isEqual from "lodash/isEqual"
import {
  HoppRESTRequest,
  HoppRESTAuthOAuth2,
  safelyExtractRESTRequest,
} from "@hoppscotch/data"
import { useSetting } from "~/newstore/settings"
import {
  restActiveParamsCount$,
  restActiveHeadersCount$,
  getRESTRequest,
  setRESTRequest,
  setRESTAuth,
  restAuth$,
  useTestScript,
  usePreRequestScript,
  getDefaultRESTRequest,
} from "~/newstore/RESTSession"
import { translateExtURLParams } from "~/helpers/RESTExtURLParams"
import {
  pluckRef,
  useReadonlyStream,
  useStream,
} from "~/helpers/utils/composables"
import { loadRequestFromSync, startRequestSync } from "~/helpers/fb/request"
import { onLoggedIn } from "~/helpers/fb/auth"
import { oauthRedirect } from "~/helpers/oauth"
import useWindowSize from "~/helpers/utils/useWindowSize"

function bindRequestToURLParams() {
  const { route } = useContext()
  // Get URL parameters and set that as the request
  onMounted(() => {
    const query = route.value.query
    // If query params are empty, or contains code or error param (these are from Oauth Redirect)
    // We skip URL params parsing
    if (Object.keys(query).length === 0 || query.code || query.error) return
    setRESTRequest(
      safelyExtractRESTRequest(
        translateExtURLParams(query),
        getDefaultRESTRequest()
      )
    )
  })
}

function oAuthURL() {
  const auth = useStream(
    restAuth$,
    { authType: "none", authActive: true },
    setRESTAuth
  )

  const oauth2Token = pluckRef(auth as Ref<HoppRESTAuthOAuth2>, "token")

  onBeforeMount(async () => {
    const tokenInfo = await oauthRedirect()
    if (Object.prototype.hasOwnProperty.call(tokenInfo, "access_token")) {
      if (typeof tokenInfo === "object") {
        oauth2Token.value = tokenInfo.access_token
      }
    }
  })
}

function setupRequestSync(
  confirmSync: Ref<boolean>,
  requestForSync: Ref<HoppRESTRequest | null>
) {
  const { route } = useContext()

  // Subscription to request sync
  let sub: Subscription | null = null

  // Load request on login resolve and start sync
  onLoggedIn(async () => {
    if (
      Object.keys(route.value.query).length === 0 &&
      !(route.value.query.code || route.value.query.error)
    ) {
      const request = await loadRequestFromSync()
      if (request) {
        // setRESTRequest(request)
        if (!isEqual(request, getRESTRequest())) {
          requestForSync.value = request
          confirmSync.value = true
        }
      }
    }

    sub = startRequestSync()
  })

  // Stop subscripton to stop syncing
  onBeforeUnmount(() => {
    sub?.unsubscribe()
  })
}

export default defineComponent({
  components: { Splitpanes, Pane },
  setup() {
    const requestForSync = ref<HoppRESTRequest | null>(null)

    const testScript = useTestScript()
    const preRequestScript = usePreRequestScript()

    const confirmSync = ref(false)

    const syncRequest = () => {
      setRESTRequest(
        safelyExtractRESTRequest(requestForSync.value!, getDefaultRESTRequest())
      )
    }

    setupRequestSync(confirmSync, requestForSync)
    bindRequestToURLParams()

    // zhangtao25 修改

    const arexTypes = ref(['常规接口测试','比对接口测试'])
    const arexType = ref('比对接口测试')
    function onSelectArexType(type:any) {
      arexType.value = type
      methodOptions.value.tippy().hide()
    }
    const methodOptions = ref<any | null>(null)

    return {
      windowInnerWidth: useWindowSize(),
      newActiveParamsCount$: useReadonlyStream(
        restActiveParamsCount$.pipe(
          map((e) => {
            if (e === 0) return null
            return `${e}`
          })
        ),
        null
      ),
      newActiveHeadersCount$: useReadonlyStream(
        restActiveHeadersCount$.pipe(
          map((e) => {
            if (e === 0) return null
            return `${e}`
          })
        ),
        null
      ),
      SIDEBAR: useSetting("SIDEBAR"),
      COLUMN_LAYOUT: useSetting("COLUMN_LAYOUT"),
      SIDEBAR_ON_LEFT: useSetting("SIDEBAR_ON_LEFT"),
      confirmSync,
      syncRequest,
      oAuthURL,
      requestForSync,
      testScript,
      preRequestScript,
      arexTypes,
      arexType,
      onSelectArexType,
      methodOptions
    }
  },
})
</script>
